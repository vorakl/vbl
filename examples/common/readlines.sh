#!/bin/bash

main() {
    source <(curl -sSLf http://lib-sh.vorakl.name/files/common)

    local _myvar

    IFS= readlines -r -d '' _myvar < /proc/$$/environ
    echo "\"${_myvar}\""
}

main
