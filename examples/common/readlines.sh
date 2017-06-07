#!/bin/bash

main() {
    source /home/vorakl/repos/my/github/lib-sh/src/common

    local _myvar

    readlines -r -d '' _myvar < /proc/$$/environ
    echo "[${_myvar}]"
}

main
