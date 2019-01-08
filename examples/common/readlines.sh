#!/bin/bash

main() {
    source <(curl -sSLf http://bash.libs.cf/latest/common)

    local _myvar

    IFS= readlines -r -d '' _myvar < /proc/$$/environ
    echo "\"${_myvar}\""
}

main
