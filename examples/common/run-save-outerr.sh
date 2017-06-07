#!/bin/bash

main() {
    source /home/vorakl/repos/my/github/lib-sh/src/common

    run --save-out my_out --save-err my_err eval '{ say "$(ls /)"; err "$(ls -l /)"; }'

    say "StdOut:"
    say "${my_out}"

    say "StdErr:"
    say "${my_err}"
}

__common_init__() {
    # Set default vaules. They can be redefined in-line for a particular command
    SAY_FORMAT="%s\n"
    ERR_FORMAT="%s\n"
}

main
