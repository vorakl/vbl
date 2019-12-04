#!/bin/echo This file has to be soursed. Use: source
# ---[exec]-----------------------------------------------------------(begin)---
# Functions related to executing commands
# https://bash.libs.cf/
# Copyright (c) 2016,17,19 by Oleksii Tsvietnov, vorakl@protonmail.com

# API:
# <var>  __exec_version
# <var>  __exec_exported
# <var>  EXEC_RUN_WARN_FORMAT
# <var>  EXEC_RUN_ENSURE_FORMAT
# <var>  EXEC_DIE_EXITCODE
# <var>  EXEC_DIE_FORMAT
# <var>  EXEC_CHECK_CMD_WARN_FORMAT
# <var>  EXEC_CHECK_CMD_ENSURE_FORMAT
# <var>  EXEC_RERUN_TRIES
# <var>  EXEC_RERUN_SLEEP
# <func> __exec_init__
# <func> exec_run
# <func> exec_check_cmd
# <func> exec_die
# <func> exec_rerun
#
# REQIRES:
# sys, str
#
# USAGE:
# source exec [list of functions to export]

exec_run() {
    # A wrapper to run commands and control output, exit status, etc
    #
    # usage:
    #   exec_run [ --silent | \
    #             (--no-out|--save-out var) | \
    #             (--no-err|--save-err var|--err-to-out) \
    #            ] \
    #            [--ignore|--warn|--ensure] \
    #            [--] \
    #            cmd [arg [...]]
    #
    # parameters:
    #   --silent        suppress stdout and stderr
    #   --no-out        suppress stdout
    #   --no-err        suppress stderr
    #   --save-out var  save stdout into array variable 'var' (up to 64 KB)
    #   --save-err var  save stderr into array variable 'var' (up to 64 KB)
    #   --err-to-out    join stderr and stdout in one stream of stdout 
    #   --ignore        ignore non zero exit status
    #   --warn          ignore non zero exit status and print an error which
    #                   is built of the ordered FORMAT's elements:
    #                   %s - errmsg, %d - exitcode
    #   --ensure        exit on any non-zero exitstatus and print an error
    #                   which is built of the ordered FORMAT's elements:
    #                   %s - errmsg, %d - exitcode, %d - die exitcode
    #
    # options:
    #   EXEC_RUN_WARN_FORMAT
    #   EXEC_RUN_ENSURE_FORMAT
    #
    # examples:
    #   exec_run --silent --ignore cat /nonexistent
    #   exec_run --err-to-out find / -name "void" | tee -a search.log
    #   exec_run --no-out --save-err myerr --warn sync_dirs /home
    #   exec_run --no-out --ensure do_backup_daily

    declare -i _silent="0" _no_out="0" _no_err="0" _err_to_out="0"
    declare -i _ignore="0" _warn="0" _ensure="0"
    declare _arg="" _line="" _status="" _save_vars="" _rc=""
    declare _channels="" _chan_out="" _chan_err="" _rnd_eof=""
    declare -i _save_out_set="0" _save_err_set="0"
    declare -n _save_out _save_err
    declare _pipe_out="/tmp/bash-libs-exec-run-$$-$RANDOM-out.pipe"
    declare _pipe_err="/tmp/bash-libs-exec-run-$$-$RANDOM-err.pipe"

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
                    silent|no-out|no-err|err-to-out|ignore|warn|ensure) 
                        eval _${_arg//-/_}="1"
                        ;;
                    save-out|save-err)
                        shift
                        eval _${_arg/-/_}='"$1"'
                        eval _${_arg/-/_}_set="1"
                        ;;
                esac
                shift
                ;;
            *)  
                break
                ;;
        esac
    done

    # analyze parameters
    if (( _silent )); then
        _channels="1>/dev/null 2>/dev/null"
    else
        if (( _no_out )); then
            _chan_out="1>/dev/null"
        elif (( _save_out_set )); then
            exec_check_cmd --ensure mkfifo
            sys_cmd -p mkfifo -m 600 ${_pipe_out} &>/dev/null || \
                exec_die "Cannot create ${_pipe_out}"
            sys_cmd exec {_pipe_out_fd}<>${_pipe_out} || \
                exec_die "Cannot assign fd ${_pipe_out_fd} to ${_pipe_out}"
            _chan_out="1>${_pipe_out}"
        else
            _chan_out=""
        fi

        if (( _no_err )); then
            _chan_err="2>/dev/null"
        elif (( _save_err_set )); then
            exec_check_cmd --ensure mkfifo
            sys_cmd -p mkfifo -m 600 ${_pipe_err} &>/dev/null || \
                exec_die "Cannot create ${_pipe_err}"
            sys_cmd exec {_pipe_err_fd}<>${_pipe_err} || \
                exec_die "Cannot assign fd ${_pipe_err_fd} to ${_pipe_err}"
            _chan_err="2>${_pipe_err}"
        elif (( _err_to_out )); then
            _chan_err="2>&1"
        else
            _chan_err=""
        fi

        _channels="${_chan_out} ${_chan_err}"
    fi

    if (( _save_out_set || _save_err_set )); then
        trap 'sys_cmd -p rm -f ${_pipe_out} ${_pipe_err} &>/dev/null; \
              trap -- RETURN' RETURN
    fi

    if (( _ignore )); then
        _status="|| sys_cmd true"
    elif (( _warn )); then
        _status='|| STR_ERR_FORMAT="${EXEC_RUN_WARN_FORMAT}" str_err "$1" "$?"'
    elif (( _ensure )); then
        _status='|| EXEC_DIE_FORMAT="${EXEC_RUN_ENSURE_FORMAT}" exec_die "$1" "$?" "${EXEC_DIE_EXITCODE}"'
    fi

    [[ "$@" ]] || exec_die "There is nothing to run!"

    eval '"$@"' ${_channels} ${_status}
    _rc="$?"

    if (( _save_out_set )); then
        _rnd_eof="${RANDOM}-${RANDOM}-${RANDOM}"
        sys_cmd echo "${_rnd_eof}" > ${_pipe_out}

        until { IFS= read -u ${_pipe_out_fd} -r _line; \
                [[ "${_line}" == "${_rnd_eof}" ]]; } do 
            _save_out+=("${_line}")
        done

        exec {_pipe_out_fd}>&-
    fi

    if (( _save_err_set )); then
        _rnd_eof="${RANDOM}-${RANDOM}-${RANDOM}"
        sys_cmd echo "${_rnd_eof}" > ${_pipe_err}
        
        until { IFS= read -u ${_pipe_err_fd} -r _line;
                [[ "${_line}" == "${_rnd_eof}" ]]; } do
            _save_err+=("${_line}")
        done

        exec {_pipe_err_fd}>&-
    fi

    return ${_rc}
}

__exec_run_conf__() {
    declare -gx EXEC_RUN_WARN_FORMAT="Command '%s' has failed with exit status %d. Ignoring...\n"
    declare -gx EXEC_RUN_ENSURE_FORMAT="Command '%s' has failed with exit status %d. Exiting (exitcode=%d)...\n"
}

exec_die() {
    # Prints an error message using 'str_err' function to the stderr and
    # exits with an appropriate exit code.
    #
    # usage:
    #   exec_die [--exitcode 0..255] [--] arg [...]
    #
    # parameters:
    #   --exitcode      set an exit code, has precedence on EXEC_DIE_EXITCODE
    #
    # options:
    #   EXEC_DIE_EXITCODE
    #   EXEC_DIE_FORMAT
    #
    # examples:
    #   exec_die "A file does not exist"
    #   exec_die --exitcode 15 "A host is not reachable"
    #   EXEC_DIE_FORMAT="FATAL: '%s' has failed with '%d' exitcode\n" \
    #       exec_die --exitcode 34 "cp" "${_rc}"

    declare _arg=""
    declare -i _exitcode="${EXEC_DIE_EXITCODE}"

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
                    exitcode)
                        shift
                        _exitcode="$1"
                        ;;
                esac
                shift
                ;;
            *)  
                break
                ;;
        esac
    done

    STR_ERR_FORMAT="${EXEC_DIE_FORMAT}" str_err "$@"
    exit ${_exitcode}
}

__exec_die_conf__() {
    declare -gix EXEC_DIE_EXITCODE="1"
    declare -gx EXEC_DIE_FORMAT="%s\n"
}

exec_check_cmd() {
    # Checks if commands exist. Return an error on the first absent command
    #
    # usage:
    #   exec_check_cmd [--warn|--ensure] [--] cmd [...]
    #
    # parameters:
    #   --warn      prints a error message about the first missing command, but
    #               doesn't return any errors, keeps checking
    #               The message's FORMAT is made of the followinf elements:
    #               %s - command
    #   --ensure    exits with an error message on the first missing command
    #               The message's FORMAT is made of the followinf elements:
    #               %s - command
    #
    # options:
    #   EXEC_CHECK_CMD_WARN_FORMAT
    #   EXEC_CHECK_CMD_ENSURE_FORMAT
    #   EXEC_CHECK_CMD_ENSURE_EXITCODE
    #
    # examples:
    #   exec_check_cmd rm
    #   exec_check_cmd --warn touch cp od
    #   EXEC_CHECK_CMD_ENSURE_FORMAT="FATAL: there is no '%s' command\n" \
    #       EXEC_CHECK_CMD_ENSURE_EXITCODE=28 \
    #       exec_check_cmd --ensure head tail mv

    declare _cmd="" _arg=""
    declare -i _warn="0" _ensure="0"

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
                    warn|ensure) 
                        eval _${_arg}="1"
                        ;;
                esac
                shift
                ;;
            *)  
                break
                ;;
        esac
    done

    for _cmd in "$@"; do
        if ! sys_cmd -v ${_cmd} &>/dev/null; then
            if (( _warn )); then
                STR_ERR_FORMAT="${EXEC_CHECK_CMD_WARN_FORMAT}" str_err "${_cmd}"
                continue 
            elif (( _ensure )); then
                EXEC_DIE_FORMAT="${EXEC_CHECK_CMD_ENSURE_FORMAT}" \
                    EXEC_DIE_EXITCODE="${EXEC_CHECK_CMD_ENSURE_EXITCODE}" \
                    exec_die "${_cmd}"
            fi
            return 1
        fi
    done
}

__exec_check_cmd_conf__() {
    declare -gx EXEC_CHECK_CMD_WARN_FORMAT="Command '%s' does not exist.\n"
    declare -gx EXEC_CHECK_CMD_ENSURE_FORMAT="Command '%s' does not exist. Exiting...\n"
    declare -gx EXEC_CHECK_CMD_ENSURE_EXITCODE="1"
}

exec_rerun() {
    # Rerun a command if it fails
    #
    # usage:
    #   exec_rerun [--tries num] [--sleep sec] [--] cmd [args]
    #
    # parameters:
    #   --tries     a number of tries to run a command
    #   --sleep     a pause in seconds between tries 
    #
    # options:
    #   EXEC_RERUN_TRIES
    #   EXEC_RERUN_SLEEP
    #
    # examples:
    #   exec_rerun bash -c 'echo fail; exit 1'
    #   exec_rerun --tries 3 ping -qc1 hostname
    #   exec_rerun --tries 6 --sleep 1 exec_run --silent ping hostname

    declare _arg=""
    declare -i _tries="${EXEC_RERUN_TRIES}" _sleep="${EXEC_RERUN_SLEEP}"
    declare -i _i="0" _rc="0"                                                      

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
                    tries|sleep)
                        shift
                        eval _${_arg}='"$1"'
                        ;;
                esac
                shift
                ;;
            *)  
                break
                ;;
        esac
    done
                                                                                
    while (( _i++ < ${_tries} )); do                                  
        sleep ${_sleep}                                               
        if { ("$@"); _rc=$?; ! (( _rc )); } then                                
            break                                                               
        fi                                                                      
    done                                                                        
                                                                                
    return ${_rc}                                                               
}

__exec_rerun_conf__() {
    declare -gix EXEC_RERUN_TRIES="5"
    declare -gix EXEC_RERUN_SLEEP="0"
}

__exec_conf__() {
    declare -grx __exec_version="v2.0.1"
    declare -gx __exec_exported="exec_run exec_die exec_check_cmd exec_rerun"

    __exec_run_conf__
    __exec_die_conf__
    __exec_check_cmd_conf__
    __exec_rerun_conf__
}

__exec_require__() {
    declare _module

    for _module in $*; do
        if ! declare -p __${_module}_imported &> /dev/null; then
            builtin command echo "FATAL: the module '${_module}' is required." >&2
            exit 1
        fi
    done
}

__exec_main__() {
    # Gets back the original meaning if it was reloaded
    unset -f builtin command return declare eval exec exit trap read shift break

    if declare -p __exec_imported &> /dev/null; then
        return
    fi

    # Checks if the required modules were imported
    __exec_require__ sys str
    # Sets default values and behaior for functions.
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
