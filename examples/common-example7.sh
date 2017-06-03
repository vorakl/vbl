#!/bin/bash

main() {
    source /home/vorakl/repos/my/github/lib-sh/common

    say "The function 'say' is exported"
    bash -c 'say hello'
    say "The function 'err' is NOT exported"
    bash -c 'err world'
}

__common_init__() {
    __common_export="cmd say"
}

main
