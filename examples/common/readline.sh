#!/bin/bash

main() {
    local _myvar

    source /home/vorakl/repos/my/github/lib-sh/common

    while readline -r -d '' _myvar; do
        echo "${_myvar}"
    done < /proc/$$/environ
}

main
