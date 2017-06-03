#!/bin/bash

main() {
    local _myvar

    source /home/vorakl/repos/my/github/lib-sh/common

    readlines -r -d '' _myvar < /proc/$$/environ
    echo "[${_myvar}]"
}

main
