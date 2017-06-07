#!/bin/bash

main() {
    source /home/vorakl/repos/my/github/lib-sh/src/common

    local _myvar

    while readline -r -d '' _myvar; do
        echo "${_myvar}"
    done < /proc/$$/environ
}

main
