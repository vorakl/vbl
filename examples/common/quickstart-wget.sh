#!/bin/bash

main() {
    # Download and include the common library without saving on a disk
    source <(wget -qO - http://lib-sh.vorakl.name/files/common)

    readlines -r -d '' envs < /proc/$$/environ
    echo -n "${envs}"
}

main
