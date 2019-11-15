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
    # A wrapper around the 'read' command. It reads from STDIN only one string.
    # It doesn't matter if it ends with a specified delimiter (like '\n') or not.
    # That's why it's safer to be used in a while loop to read a stream
    # which may not have a delimiter at the end of a last string.
    #
    # usage:
    #    readline [arg [...]] var [var [...]]
    #
    # parameters:
    #    arg - an argument for the 'read' command
    #    var - one or more variables. At least one has to be defined!

    eval local _var="\${$#}" # set to a variable name (the last parameter).

    if ! IFS= read "$@"; then # the 'read' command has faced to the EOF
        eval '[[ "${'${_var}'}" ]]' # check if there is a string without '\n' at the end
    fi
}

str_readlines() {
    # A wrapper around 'read' command.
    # Instead of the 'readline' it reads from STDIN the whole stream
    # which consists of one or more strings (a string's delimiter can be set as usually for 'read'
    # command, using -d option) and saves it in a specified variable 'var'.
    # It also behaves correctly if there is no a delimiter at the end of a last string.
    # IMPORTANT: each string on the output is always extended by '\n' before saving it to
    # the 'var' variable. That means, a specified variable will have all common strings ending
    # with '\n' (and the last string also!) and no matter how these strings were separated on the input.
    #
    # usage:
    #    readlines [arg [...]] var
    #
    # parameters:
    #    arg - arguments for the 'read' command
    #    var - the only one variable name. It has to be defined!

    declare _var_all=""
    eval local _var="\${$#}" # set to a variable name (the last parameter).

    while str_readline "$@"; do
        eval printf -v _var_all '"%s\n"' '"${_var_all}${'${_var}'}"'
    done

    eval ${_var}='"${_var_all}"'
}

str_format() {
    # This is a wrapper around printf which allows you to have a formated output
    # for data taken from stdin. In this case the whole stream is considered
    # as one blob until it faces '\0' or EOF. Although, it's possible to use
    # the last parameter (input) as a source of data.
    # An output can be sent to another variable or to the stdout if '-' was used
    # as a variable's name.
    #
    # usage:
    #   format format_string [output_var|-] [input]
    #
    # parameters:
    #   format_string       a common printf's format string
    #   output_var or -     a variable where to save output.
    #                       If it's empty or '-', then prints to the stdout
    #   input               if set, then it's used as a source of data.
    #                       In this case, the second parameter cannot be empty!

    declare _format="$1" _return="$2" _input="$3"

    if [[ -z "${_input}" ]]; then
        str_readline -r -d '' _input
    fi

    if [[ -n "${_return}" && "${_return}" != "-" ]]; then
        sys_cmd printf -v "${_return}" "${_format}" "${_input}"
    else
        sys_cmd printf "${_format}" "${_input}"
    fi
}

str_rstrip() {
    # It removes from the right all occurrences of a specified pattern
    # It's important to notice that the function reads the whole stream
    # as one blob until it faces '\0' or the end of data.
    # All other special symbols are treated as normal, including '\n'.
    # The result can be saved to a variable or sent to stdout without adding
    # '\n' to the end, as is.
    #
    # usage:
    #   rstrip pattern [var]
    #
    # parameters:
    #   pattern     a pattern to be removed
    #   var         a variable where the result will be saved, optional

    declare _out="" _tmp="" _pattern="$1" _return="$2"

    str_readline -r -d '' _out

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
    # It removes from the left all occurrences of a specified pattern
    # It's important to notice that the function reads the whole stream
    # as one blob until it faces '\0' or the end of data.
    # All other special symbols are treated as normal, including '\n'.
    # The result can be saved to a variable or sent to stdout without adding
    # '\n' to the end, as is.
    #
    # usage:
    #   lstrip pattern [var]
    #
    # parameters:
    #   pattern     a pattern to be removed
    #   var         a variable where the result will be saved, optional

    declare _out="" _tmp="" _pattern="$1" _return="$2"

    str_readline -r -d '' _out

    until { _tmp="${_out#$_pattern}"; [[ "${_out}" == "${_tmp}" ]]; } do
        _out="${_tmp}"
    done

    if [[ "${_return}" ]]; then
        sys_cmd printf -v "${_return}" "%s" "${_out}"
    else
        sys_cmd printf "%s" "${_out}"
    fi
}

__str_conf__() {
    declare -grx __str_version="v2.0.0"
    declare -gx __str_exported="str_say str_debug str_err str_readline
                           str_readlines str_format str_lstrip str_rstrip"

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
