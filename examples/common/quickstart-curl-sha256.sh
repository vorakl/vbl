#!/bin/bash

main() {
    # Download the common library in a current directory
    # Check sha256 hash
    # Remove the library on exit
    curl -sSLfo common http://lib-sh.vorakl.name/files/common && \
    trap 'rm -f common' EXIT TERM HUP INT && \
    curl -sSLf http://lib-sh.vorakl.name/files/common.sha256 | sha256sum --quiet -c && \
    source common || \
    { echo "The library hasn't been loaded" >&2; exit 1; }

    local _envs="" _i="0"

    while ((++_i)); readline -r -d '' _envs; do
        echo "${_envs}" | format "env ${_i}: %s"
    done < /proc/$$/environ
}

main
