#!/bin/bash

start() {
    source <(curl -sSLf http://vbl.vorakl.com/latest/sys)
    source <(curl -sSLf http://vbl.vorakl.com/latest/str)
    source <(curl -sSLf http://vbl.vorakl.com/latest/exec)

    STR_SAY_FORMAT="\n>>> %s\n" \
        str_say "Stdout goes to the pipe, stderr goes to the terminal"
    exec_run eval '{ str_say "hello"; str_err "world"; }' | \
        { a=$(cat); echo "[$a]"; }

    STR_SAY_FORMAT="\n>>> %s\n" \
        str_say "Stdout is suppressed, stderr goes to the terminal"
    exec_run --no-out eval '{ str_say "hello"; str_err "world"; }' | \
        { a=$(cat); echo "[$a]"; }

    STR_SAY_FORMAT="\n>>> %s\n" \
        str_say "Stdout goes to the pipe, stderr is suppressed"
    exec_run --no-err eval '{ str_say "hello"; str_err "world"; }' | \
        { a=$(cat); echo "[$a]"; }

    STR_SAY_FORMAT="\n>>> %s\n" \
        str_say "Both streams go to the pipe"
    exec_run --err-to-out eval '{ str_say "hello"; str_err "world"; }' | \
        { a=$(cat); echo "[$a]"; }

    STR_SAY_FORMAT="\n>>> %s\n" \
        str_say "Both streams are suppressed"
    exec_run --silent eval '{ str_say "hello"; str_err "world"; }' | \
        { a=$(cat); echo "[$a]"; }
}

__exec_init__() {
    # Set default vaules. They can be redefined in-line for a particular command
    STR_SAY_FORMAT="INFO:  %-70.70s\n"
    STR_ERR_FORMAT="ERROR: %-70.70s\n"
}

start
