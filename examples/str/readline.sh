#!/bin/bash

start() {
    source <(curl -sSLf http://bash.libs.cf/latest/sys)
    source <(curl -sSLf http://bash.libs.cf/latest/str)

    local _myvar

    while str_readline --delim '' _myvar; do
        echo "${_myvar}"
    done < /proc/self/environ

    # the result should contain all 3 strings and first 2 start with spaces
    printf '  Hi!\n    How are you?\nBye' | \
        while str_readline _myvar; do echo "${_myvar}"; done
}

start
