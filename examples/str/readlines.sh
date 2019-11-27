#!/bin/bash

start() {
    source <(curl -sSLf http://bash.libs.cf/latest/sys)
    source <(curl -sSLf http://bash.libs.cf/latest/str)

    local _myvar

    str_readlines --delim '' _myvar < /proc/$$/environ

    for i in "${!_myvar[@]}"; do
        echo "${_myvar[i]}"
    done
}

start
