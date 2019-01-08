#!/bin/bash

main() {
    source <(curl -sSLf http://bash.libs.cf/latest/common)

    SAY_FORMAT="\n>>> %s\n" say "Stdout goes to the pipe, stderr goes to the terminal"
    run eval '{ say "hello"; err "world"; }' | { a=$(cat); echo "[$a]"; }

    SAY_FORMAT="\n>>> %s\n" say "Stdout is suppressed, stderr goes to the terminal"
    run --no-out eval '{ say "hello"; err "world"; }' | { a=$(cat); echo "[$a]"; }

    SAY_FORMAT="\n>>> %s\n" say "Stdout goes to the pipe, stderr is suppressed"
    run --no-err eval '{ say "hello"; err "world"; }' | { a=$(cat); echo "[$a]"; }

    SAY_FORMAT="\n>>> %s\n" say "Both streams go to the pipe"
    run --join-outerr eval '{ say "hello"; err "world"; }' | { a=$(cat); echo "[$a]"; }

    SAY_FORMAT="\n>>> %s\n" say "Both streams are suppressed"
    run --silent eval '{ say "hello"; err "world"; }' | { a=$(cat); echo "[$a]"; }
}

__common_init__() {
    # Set default vaules. They can be redefined in-line for a particular command
    SAY_FORMAT="INFO:  %-70.70s\n"
    ERR_FORMAT="ERROR: %-70.70s\n"
}

main
