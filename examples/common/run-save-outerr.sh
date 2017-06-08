#!/bin/bash

main() {
    source <(curl -sSLf http://lib-sh.vorakl.name/files/common)

    run --save-out my_out --save-err my_err eval '{ say "$(top -bn1)"; err "$(ls -l /)"; }'

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
