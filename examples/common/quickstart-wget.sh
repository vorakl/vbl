#!/bin/bash

main() {
    # Download and include the common library without saving on a disk
    source <(wget -qO - http://bash.libs.cf/latest/common)

    readlines -r -d '' envs < /proc/$$/environ
    echo -n "${envs}"
}

main
