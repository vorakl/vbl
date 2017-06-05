#!/bin/bash

main() {
    source /home/vorakl/repos/my/github/lib-sh/common

    set -e  # `run` controls behavior on errors even with "-e" option  

    say_format="\n>>> %s\n" say "Running compound commands"
    run eval 'for i in a "b c" d; do echo "[$i]"; done'

    say_format="\n>>> %s\n" say "Ignore errors, 'set -e' will not stop the script"
    run --ignore cat /asd
    echo "You still see this"

    say_format="\n>>> %s\n" say "Ignore errors, hide an error message"
    run --ignore --no-err eval '{ echo "I am going to run a wrong command"; cat /asd; }'
    say "The current exit status: $?"

    say_format="\n>>> %s\n" say "Ignore errors, hide an error message, write my own 'warn' message"
    run --warn --no-err eval '{ echo "I am going to run a wrong command"; cat /asd; }'
    say "The current exit status: $?"

    say_format="\n>>> %s\n" say "Exit on errors, hide an error message, write my own 'error' message"
    run --ensure --no-err eval '{ echo "I am going to run a wrong command"; cat /asd; }'

    say "You will never see this"
}

__common_init__() {
    # Set default vaules. They can be redefined in-line for a particular command
    say_format="INFO:  %-70.70s\n"
    err_format="ERROR: %-70.70s\n"
    die_exitcode="13"
}

main
