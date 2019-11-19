#!/bin/bash

start() {
    source <(curl -sSLf http://bash.libs.cf/latest/sys)
    source <(curl -sSLf http://bash.libs.cf/latest/str)
    source <(curl -sSLf http://bash.libs.cf/latest/exec)

    exec_run --save-out my_out --save-err my_err \
        eval '{ str_say "$(top -bn1)"; str_err "$(ls -l /)"; }'

    str_say "StdOut:"
    (IFS=$'\n'; str_say "${my_out[*]}")
    echo
    str_say "StdErr:"
    (IFS=$'\n'; str_say "${my_err[*]}")
}

start
