#!/bin/bash

main() {
    source /home/vorakl/repos/my/github/lib-sh/common

    run --save-out my_out --save-err my_err eval '{ say "$(ls /)"; err "$(ls -l /)"; }'

    say "StdOut:"
    say "${my_out}"

    say "StdErr:"
    say "${my_err}"
}

__common_init__() {
    # Set default vaules. They can be redefined in-line for a particular command
    say_format="%s\n"
    err_format="%s\n"
    die_exitcode="13"
}

main
