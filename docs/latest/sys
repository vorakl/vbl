#!/bin/echo This file has to be sourced. Use: source
# ---[sys]------------------------------------------------------------(begin)---
# Copyright (c) 2016 by Oleksii Tsvietnov
# SPDX-License-Identifier: MIT
#
# Essential system functions
#
# API:
# <var>  __sys_version
# <var>  __sys_exported
# <func> __sys_init__
# <func> sys_cmd
#
# USAGE:
# source sys [list of functions to export]

sys_cmd() {
    # A wrapper for the builtin 'command' for minimizing a risk of reloading
    # It works together with 'unset builtin' in the __sys_conf__ and
    # the whole idea will work out only if Bash is run with the '--posix' option
    # which doesn't allow to reload 'unset' builtin function.
    # Anyway, you decide how deep is your paranoia ;)
    # It's intended to be used for running builtin commands or standard tools.
    # First, it checks in builtins. Then, it tries to find an external command.
    #
    # usage:
    #   sys_cmd arg [...]
    #
    # parameters:
    #   All parameters of the 'cmd' command. For instance:
    #   -p  search in standard paths only
    #   -v  check if a command exists
    #
    # examples:
    #   sys_cmd echo "Hello World"
    #   sys_cmd -v cp
    #   sys_cmd -p df -h

    builtin command "$@"
}

__sys_export_func__() {
    declare _func=""

    for _func in $*; do
        declare -fgx "${_func}"
    done
}

__sys_conf__() {
    declare -grx __sys_version="v2.0.3"
    declare -gx __sys_exported="sys_cmd"
}

__sys_main__() {
    # gets back the original meaning if it was reloaded
    unset -f builtin command return declare

    # prevents reimporting
    if declare -p __sys_imported &> /dev/null; then
        return
    fi

    __sys_conf__  # Set default values and behaior for functions.

    if declare -F __sys_init__ &> /dev/null; then
        # If a function is defined in code, then execute it.
        # This is the way to configure functions for your needs.
        __sys_init__
    fi

    if [[ -n "$*" ]]; then
        __sys_exported=$*
    fi

    __sys_export_func__ ${__sys_exported}

    declare -rgx __sys_imported="true"
}

# The entrypoint
__sys_main__ $*
# ---[sys]--------------------------------------------------------------(end)---
