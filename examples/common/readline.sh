#!/bin/bash

main() {
    source <(curl -sSLf http://lib-sh.vorakl.name/files/common)

    local _myvar

    while readline -r -d '' _myvar; do
        echo "${_myvar}"
    done < /proc/$$/environ
}

main
