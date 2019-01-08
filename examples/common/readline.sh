#!/bin/bash

main() {
    source <(curl -sSLf http://bash.libs.cf/latest/common)

    local _myvar

    while IFS= readline -r -d '' _myvar; do
        echo "${_myvar}"
    done < /proc/$$/environ
}

main
