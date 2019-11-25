#!/bin/echo This file has to be soursed. Use: source
# ---[str]------------------------------------------------------------(begin)---
# Functions for strings processing
# https://bash.libs.cf/
# Copyright (c) 2016,17,19 by Oleksii Tsvietnov, vorakl@protonmail.com

# API:
# <var>  __str_version
# <var>  __str_exported
# <var> STR_SAY_SUPPRESS
# <var> STR_SAY_FORMAT
# <var> STR_DEBUG_SUPPRESS
# <var> STR_DEBUG_FORMAT
# <var> STR_ERR_SUPPRESS
# <var> STR_ERR_FORMAT
# <func> __str_init__
# <func> str_say
# <func> str_debug
# <func> str_err
# <func> str_readline
# <func> str_readlines
# <func> str_format
# <func> str_lstrip
# <func> str_rstrip
# <func> str_strip
#
# REQIRES:
# sys
#
# USE:
# sourse module_name [list of functions to export]

str_say() {
    # Prints to stdout with an ability to set a format
    #
    # usage:
    #   str_say arg [...]
    #
    # options:
    #   STR_SAY_SUPPRESS
    #   STR_SAY_FORMAT
    #
    # examples:
    #   str_say "Hello World"
    #   STR_SAY_FORMAT="INFO [%s]: %s\n" str_say "main" "Loading to memory..."

    (( STR_SAY_SUPPRESS )) || sys_cmd printf "${STR_SAY_FORMAT}" "$@"
}

__str_say_conf__() {
    declare -gx STR_SAY_SUPPRESS="0"
    declare -gx STR_SAY_FORMAT="%s\n"
}

str_debug() {
    # Prints to stdout as 'say' does but only if debug_suppress is turned off.
    # It's useful for having a controlled higher level of verbosity.
    #
    # usage:
    #   str_debug arg [...]
    #
    # options:
    #   STR_DEBUG_SUPPRESS
    #   STR_DEBUG_FORMAT
    #
    # examples:
    #   STR_DEBUG_SUPPRESS=0 \
    #       STR_DEBUG_FORMAT="DEBUG: %s\n" \
    #       str_debug "The queue is empty"

    (( STR_DEBUG_SUPPRESS )) || sys_cmd printf "${STR_DEBUG_FORMAT}" "$@"
}

__str_debug_conf__() {
    declare -gx STR_DEBUG_SUPPRESS="1"
    declare -gx STR_DEBUG_FORMAT="%s\n"
}

str_err() {
    # Prints to stderr with an ability to set a format
    #
    # usage:
    #   str_err arg [...]
    #
    # options:
    #   STR_ERR_SUPPRESS
    #   STR_ERR_FORMAT
    #
    # examples:
    #   str_err "The connection has been closed"
    #   STR_ERR_FORMAT="WARN: %s\n" str_err "too much arguments"

    (( STR_ERR_SUPPRESS )) || sys_cmd printf "${STR_ERR_FORMAT}" "$@" >&2
}

__str_err_conf__() {
    declare -gx STR_ERR_SUPPRESS="0"
    declare -gx STR_ERR_FORMAT="%s\n"
}

str_readline() {
    # Reads symbols from stdin or a file descriptor, until it faced a delimiter
    # or the EOF. The delimiter can be defined. It also doesn't matter if
    # a string ends with a specified  delimiter (by default it's '\n') or not.
    # That's why it's much safer to be used in a while loop to read a stream
    # which may not have a defined delimiter at the end of the last string.
    #
    # usage:
    #    str_readline [--delim char] [--fd num] [--] var
    #
    # parameters:
    #    --delim    A delimiter of a string (default is '\n')
    #    --fd       A file descriptor to read from (default is 0)
    #    var        A variable for storing a result
    #
    # examples:
    #   # the result should contain all 3 strings and first 2 start with spaces
    #   printf '  Hi!\n    How are you?\nBye' | \
    #       while str_readline str; do echo "${str}"; done
    #
    #   # reads strings which end with \0 symbol instead of \n
    #   cat /proc/self/environ | \
    #       while str_readline --delim '' str; do echo "[${str}]"; done
    #
    #   # reads from a file descriptor
    #   { mkfifo /tmp/my.pipe;
    #     exec {mypipe}<>/tmp/my.pipe;
    #     cat /etc/passwd > /tmp/my.pipe;
    #     while str_readline --fd ${mypipe} str; do echo "${str}"; done;
    #     exec {mypipe}<&-;
    #     rm -f /tmp/my.pipe; }

    declare -n _var
    declare _arg=""
    declare -i _fd="0"
    declare _delim=$'\n'

    # parse param string
    while [[ "$@" ]]; do
        case "$1" in
            --) 
                shift
                break
                ;;
            --*) 
                _arg="${1#--}"
                case "${_arg}" in
                    delim)
                        shift
                        _delim="$1"
                        ;;
                    fd)
                        shift
                        _fd="$1"
                        ;;
                    *)  ;;
                esac
                shift
                ;;
            *)  
                _var="$1"
                break
                ;;
        esac
    done

    if ! IFS= sys_cmd read -d "${_delim}" -u ${_fd} -r _var; then
        [[ "${_var}" ]]
    fi
}

str_readlines() {
    # Reads strings from the stdin until it faced the EOF and save
    # them in an array. It also behaves correctly if there is no a delimiter
    # at the end of the last string.
    #
    # usage:
    #    str_readlines [--delim char] [--fd num] [--] arr
    #
    # parameters:
    #    --delim    A delimiter of a string (default is $'\n')
    #    --fd       A file descriptor to read from (default is 0)
    #    arr        An array variable for storing the result
    #
    # examples:
    #   # reads strings which end with '\0' symbol instead of '\n'
    #   str_readlines --delim $'\0' myenv < /proc/self/environ && \
    #       echo "${myenv[0]}"

    declare -n _arr
    declare _str="" _arg=""
    declare -i _fd="0"
    declare _delim=$'\n'

    # parse param string
    while [[ "$@" ]]; do
        case "$1" in
            --) 
                shift
                break
                ;;
            --*) 
                _arg="${1#--}"
                case "${_arg}" in
                    delim)
                        shift
                        _delim="$1"
                        ;;
                    fd)
                        shift
                        _fd="$1"
                        ;;
                    *)  ;;
                esac
                shift
                ;;
            *)  
                _arr="$1"
                break
                ;;
        esac
    done

    while str_readline --delim "${_delim}" --fd ${_fd} _str; do
        _arr+=("${_str}")
    done
}

str_format() {
    # This is a wrapper around printf which allows you to have a formated output
    # for data taken from the stdin. In this case the whole stream is considered
    # as one blob until it faces '\0' or EOF. It is also possible to define
    # as an input the last parameter (input) as a source of data instead
    # of using the stdin. An output can be sent to another variable or
    # to the stdout if '-' was used instead of a variable's name.
    #
    # usage:
    #   str_format format_string [output_var|-] [input]
    #
    # parameters:
    #   format_string       A common printf's format string
    #   output_var or -     A variablei for saving the output.
    #                       If it's empty or '-', then prints to the stdout
    #   input               If it's set, then it's used as a source of data.
    #                       In this case, the second parameter cannot be empty!
    # examples:
    #   str_format "%014.2f" my_float "1.48732599" && echo ${my_float}
    #   str_format "The current time: %(%H:%M:%S)T\n" - "$(date '+%s')"
    #   echo -ne 'Hello\nWorld' | str_format "[%s]\n"

    declare _format="$1" _return="$2" _input="$3"

    if [[ -z "${_input}" ]]; then
        str_readline --delim '' _input
    fi

    if [[ -n "${_return}" && "${_return}" != "-" ]]; then
        sys_cmd printf -v "${_return}" "${_format}" "${_input}"
    else
        sys_cmd printf "${_format}" "${_input}"
    fi
}

str_rstrip() {
    # Removes all occurrences of a specified pattern from the right side.
    # It's important to notice that the function reads the whole stream
    # as one blob until it faces '\0' or the end of data.
    # All other special symbols are treated as normal, including '\n'.
    # The result can be saved to a variable or sent to the stdout without adding
    # '\n' to the end, as is.
    #
    # usage:
    #   str_rstrip [pattern] [var]
    #
    # parameters:
    #   pattern     A pattern is the same as in pathname expansion
    #               Default is a new line (\n)
    #   var         A variable where the result will be saved, optional
    #
    # examples:
    #   str_rstrip < <(printf "Hello\n\n\n\n")

    declare _out="" _tmp="" _pattern="$1" _return="$2"

    if [[ -z "${_pattern}" ]]; then
        _pattern=$'\n'
    fi

    str_readline --delim '' _out

    until { _tmp="${_out%$_pattern}"; [[ "${_out}" == "${_tmp}" ]]; } do
        _out="${_tmp}"
    done

    if [[ "${_return}" ]]; then
        sys_cmd printf -v "${_return}" "%s" "${_out}"
    else
        sys_cmd printf "%s" "${_out}"
    fi
}

str_lstrip() {
    # Removes all occurrences of a specified pattern from the left side.
    # It's important to notice that the function reads the whole stream
    # as one blob until it faces '\0' or the end of data.
    # All other special symbols are treated as normal, including '\n'.
    # The result can be saved to a variable or sent to stdout without adding
    # '\n' to the end, as is.
    #
    # usage:
    #   str_lstrip [pattern] [var]
    #
    # parameters:
    #   pattern     A pattern is the same as in pathname expansion
    #               Default is a space (" ")
    #   var         A variable where the result will be saved, optional
    #
    # examples:
    #   str_lstrip <<< "     Hello"

    declare _out="" _tmp="" _pattern="$1" _return="$2"

    if [[ -z "${_pattern}" ]]; then
        _pattern=" "
    fi

    str_readline --delim '' _out

    until { _tmp="${_out#$_pattern}"; [[ "${_out}" == "${_tmp}" ]]; } do
        _out="${_tmp}"
    done

    if [[ "${_return}" ]]; then
        sys_cmd printf -v "${_return}" "%s" "${_out}"
    else
        sys_cmd printf "%s" "${_out}"
    fi
}

str_strip() {
    # Removes all occurrences of a specified pattern from both sides.
    # Keep in mind that usualy strings end with a new line symbol '\n' and
    # to use this function, first you need to remove it from the right.
    #
    # usage:
    #   str_strip [pattern] [var]
    #
    # parameters:
    #   pattern     A pattern is the same as in pathname expansion
    #               Default is a space (" ")
    #   var         A variable where the result will be saved, optional
    #
    # examples:
    #   { str_rstrip | str_strip | str_format "[%s]\n"; } <<< "   Hello     "

    declare _pattern="$1" _return="$2"

    if [[ -z "${_pattern}" ]]; then
        _pattern=" "
    fi

    if [[ -z "${_return}" ]]; then
        str_lstrip "${_pattern}" | str_rstrip "${_pattern}"
    else
        str_lstrip "${_pattern}" "${_return}"
        str_rstrip "${_pattern}" "${_return}" < <(eval printf "\$${_return}")
    fi
}

__str_conf__() {
    declare -grx __str_version="v2.0.0"
    declare -gx __str_exported="str_say str_debug str_err str_readline
                      str_readlines str_format str_lstrip str_rstrip str_strip"

    __str_say_conf__
    __str_debug_conf__
    __str_err_conf__
}

__str_require__() {
    declare _module

    for _module in $*; do
        if ! declare -p __${_module}_imported &> /dev/null; then
            builtin command echo "FATAL: the module '${_module}' is required. " >&2
            exit 1
        fi
    done
}

__str_main__() {
    # gets back the original meaning if it was reloaded
    unset -f builtin command return declare local export eval exit read

    if declare -p __str_imported &> /dev/null; then
        return
    fi

    # Check if all required modules have been imported.
    __str_require__ sys
    # Set default values and behaior for functions.
    __str_conf__

    if declare -F __str_init__ &> /dev/null; then
        # If a function is defined in code, then execute it.
        # This is the way to configure functions for your needs.
        __str_init__
    fi

    if [[ -n "$*" ]]; then
        __str_exported=$*
    fi

    __sys_export_func__ ${__str_exported}

    declare -grx __str_imported="true"
}

# The entrypoint
__str_main__ $*
# ---[str]--------------------------------------------------------------(end)---
