#!/bin/echo This file has to be soursed. Use: source
# ---[exec]-----------------------------------------------------------(begin)---
# Functions related to executing commands
# https://bash.libs.cf/
# Copyright (c) 2016,17,19 by Oleksii Tsvietnov, vorakl@protonmail.com

# API:
# <var>  __exec_version        a version of the module
# <var>  __exec_exported       a list of functions to be exported
# <var>  $*                    overrides __exec_exported if it's nonempty
# <var> EXEC_RUN_WARN_FORMAT
# <var> EXEC_RUN_ENSURE_FORMAT
# <var> EXEC_DIE_EXITCODE
# <func> __exec_init__         an init functions, runs when a lib is imported
# <func> exec_run              a wrapper for running commands in a controlled way
# <func> exec_die              prints an error and exists with a certain exitcode
# <func> exec_rerun            run a command N times with a pause if it fails
#
# USE:
# sourse module_name [list of functions to export]

exec_run() {
    # A wrapper to run commands and control output, exit status, etc
    #
    # usage:
    #   run [--silent|--no-out|--no-err] \
    #       [--save-out var|--save-err var] \
    #       [--join-outerr] \
    #       [--ignore|--warn|--ensure] \
    #       [--] \
    #       cmd [arg [...]]
    #
    # parameters:
    #   --silent        suppress stdout and stderr
    #   --no-out        suppress stdout
    #   --no-err        suppress stderr
    #   --save-out var  save stdout into 'var' variable (up to 64 KB)
    #   --save-err var  save stderr into 'var' variable (up to 64 KB)
    #   --join-outerr   join stdout and stderr in one stream of stdout 
    #   --ignore        ignore non zero exit status
    #   --warn          ignore non zero exit status and write an error message
    #   --ensure        exit on any non zero exit status
    #
    # options:
    #   EXEC_RUN_WARN_FORMAT
    #   EXEC_RUN_ENSURE_FORMAT

    declare _arg="" _line="" _channels="" _status="" _save_vars="" _rc=""
    declare -i _silent="0" _no_out="0" _no_err="0" _join_outerr="0"
    declare _save_out="" _save_err=""
    declare -i _ignore="0" _warn="0" _ensure="0"
    declare _pipe_out="/tmp/lib-sh-exec-$$-$RANDOM-out.pipe"
    declare _pipe_err="/tmp/lib-sh-exec-$$-$RANDOM-err.pipe"

    while [[ "$@" ]]; do
        case "$1" in
            --) 
                shift
                break
                ;;
            --*) 
                _arg="${1#--}"
                case "${_arg}" in
                    silent|no-out|no-err|join-outerr|ignore|warn|ensure) 
                        eval _${_arg/-/_}="1"
                        ;;
                    save-out|save-err)
                        shift
                        eval _${_arg/-/_}="$1"
                        ;;
                esac
                shift
                ;;
            *)  
                break
                ;;
        esac
    done

    if (( _silent )); then
        _channels="1>/dev/null 2>/dev/null"
    elif (( _no_out )); then
        _channels="1>/dev/null"
    elif (( _no_err )); then
        _channels="2>/dev/null"
    elif (( _join_outerr )); then
        _channels="2>&1"
    fi

    if [[ "${_save_out}" ]]; then
        cmd -v mkfifo &>/dev/null || die "The 'mkfifo' tool does not exist"
        cmd -p mkfifo -m 600 ${_pipe_out} &>/dev/null || die "Cannot create ${_pipe_out}"
        exec 3<>${_pipe_out} || die "Cannot assign fd 3 to ${_pipe_out}"
        _save_vars="${_save_vars} 1>${_pipe_out}"
    fi

    if [[ "${_save_err}" ]]; then
        cmd -v mkfifo &>/dev/null || die "The 'mkfifo' tool does not exist"
        cmd -p mkfifo -m 600 ${_pipe_err} &>/dev/null || die "cannot create ${_pipe_err}"
        exec 4<>${_pipe_err} || die "Cannot assign fd 4 to ${_pipe_err}"
        _save_vars="${_save_vars} 2>${_pipe_err}"
    fi

    if [[ "${_save_out}" || "${_save_err}" ]]; then
        trap 'cmd -p rm -f ${_pipe_out} ${_pipe_err} &>/dev/null; \
              trap -- RETURN; trap -- ERR' RETURN ERR
    fi

    if (( _ignore )); then
        _status="|| cmd true"
    elif (( _warn )); then
        _status='|| STR_ERR_FORMAT="${EXEC_RUN_WARN_FORMAT}" err "$1" "$?"'
    elif (( _ensure )); then
        _status='|| STR_ERR_FORMAT="${EXEC_RUN_ENSURE_FORMAT}" die "$1" "$?" "${EXEC_DIE_EXITCODE}"'
    fi

    [[ "$@" ]] || die "There is nothing to run!"

    eval '"$@"' ${_save_vars} ${_channels} ${_status}
    _rc="$?"

    if [[ "${_save_out}" ]]; then
        cmd echo "-=STOP=-" > ${_pipe_out}

        until { IFS= read -u 3 -r _line; [[ "${_line}" == "-=STOP=-" ]]; } do 
            eval printf -v ${_save_out} '"%s\n"' '"${'${_save_out}'}${_line}"'
        done

        exec 3>&-
    fi

    if [[ "${_save_err}" ]]; then
        cmd echo "-=STOP=-" > ${_pipe_err}

        until { IFS= read -u 4 -r _line; [[ "${_line}" == "-=STOP=-" ]]; } do 
            eval printf -v ${_save_err} '"%s\n"' '"${'${_save_err}'}${_line}"'
        done

        exec 4>&-
    fi

    sys_cmd return ${_rc}
}

__exec_run_conf__() {
    export EXEC_RUN_WARN_FORMAT="Command \'%s\' has failed with exit status %d. Ignoring..."
    export EXEC_RUN_ENSURE_FORMAT="Command \'%s\' has failed with exit status %d. Exiting (exitcode=%d)..."
}

exec_die() {
    # Print an error message using 'err' command to the stderr and
    # exit with an appropriate exit code.
    #
    # options:
    #   EXEC_DIE_EXITCODE

    str_err "$@"
    sys_cmd exit ${EXEC_DIE_EXITCODE}
}

__exec_die_conf__() {
    export EXEC_DIE_EXITCODE="1"
}

exec_rerun() {
    :
}

__exec_conf__() {
    declare -grx __exec_version="v2.0.0"
    declare -gx __exec_exported="exec_run exec_die exec_rerun"

    __exec_run_conf__
    __exec_die_conf__
}

__exec_require__() {
    declare _module

    for _module in $*; do
        if ! declare -p __${_module}_imported &> /dev/null; then
            builtin command echo "FATAL: the module '${_module}' is required." >&2
            builtin command exit 1
        fi
    done
}

__exec_main__() {
    # gets back the original meaning if it was reloaded
    unset -f builtin command return declare eval

    if declare -p __exec_imported &> /dev/null; then
        return
    fi

    # Check if the required modules were imported
    __exec_require__ sys str
    # Set default values and behaior for functions.
    __exec_conf__

    if declare -F __exec_init__ &> /dev/null; then
        # If a function is defined in code, then execute it.
        # This is the way to configure functions for your needs.
        __exec_init__
    fi

    if [[ -n "$*" ]]; then
        __exec_exported=$*
    fi

    __sys_export_func__ ${__exec_exported}

    declare -grx __exec_imported="true"
}

# The entrypoint
__exec_main__ $*
# ---[exec]-------------------------------------------------------------(end)---