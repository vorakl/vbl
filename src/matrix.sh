#!/bin/echo This file has to be soursed. Use: source
# ---[matrix]---------------------------------------------------------(begin)---
# Matrix (2D-arrays) ADT
# https://bash.libs.cf/
# Copyright (c) 2019 by Oleksii Tsvietnov, vorakl@protonmail.com

# API:
# <var>  __matrix_version
# <var>  __matrix_exported
# <var>  MATRIX_GET_FORMAT
# <func> __matrix_init__
# <func> matrix_init
# <func> matrix_get
# <func> matrix_set
# <func> matrix_destroy
#
# REQIRES:
# sys, str
#
# USE:
# sourse module_name [list of functions to export]
#
# EXAMPLE:
# matrix_init my_matrix \
#            3 2 \
#            one two three \
#            "1 1" "2 2" "3 3"
# matrix_get my_matrix 1 1
# matrix_set my_matrix 1 1 "4 4 4"
# matrix_get my_matrix 1 1
# matrix_destroy my_matrix

matrix_init() {
    declare -n self=$1
    declare -i width=$2 height=$3
    shift 3;

    self=(${width} ${height} "$@")
}

matrix_get() {
    # options:
    #   MATRIX_GET_FORMAT

    declare -n self="$1"
    declare -i x="$2" y="$3"
    declare -i width="${self[0]}" height="${self[1]}"

    STR_SAY_FORMAT="${MATRIX_GET_FORMAT}" str_say "${self[2+y*width+x]}"
}

__matrix_get_conf__() {
    declare -gx MATRIX_GET_FORMAT="%s\n"
}

matrix_set() {
    declare -n self="$1"
    declare -i x="$2" y="$3"
    declare data="$4"
    declare -i width="${self[0]}" height="${self[1]}"

    self[2+y*width+x]="${data}"
}

matrix_destroy() {
    declare -n self="$1"
    unset self
}

__matrix_conf__() {
    declare -rgx __matrix_version="v2.0.0"
    declare -gx __matrix_exported="matrix_init matrix_get matrix_set matrix_destroy"

    __matrix_get_conf__
}

__matrix_require__() {
    declare _module

    for _module in $*; do
        if ! declare -p __${_module}_imported &> /dev/null; then
            builtin command echo "FATAL: the module '${_module}' is required. " >&2
            exit 1
        fi
    done
}

__matrix_main__() {
    # gets back the original meaning if it was reloaded
    unset -f builtin command return declare eval exit

    if declare -p __matrix_imported &> /dev/null; then
        return
    fi

    # Check if all required modules have been imported.
    __matrix_require__ sys str
    # Set default values and behaior for functions.
    __matrix_conf__

    if declare -F __matrix_init__ &> /dev/null; then
        # If a function is defined in code, then execute it.
        # This is the way to configure functions for your needs.
        __matrix_init__
    fi

    if [[ -n "$*" ]]; then
        __matrix_exported=$*
    fi

    __sys_export_func__ ${__matrix_exported}

    declare -rgx __matrix_imported="true"
}

# The entrypoint
__matrix_main__ $*
# ---[matrix]-----------------------------------------------------------(end)---
