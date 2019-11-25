#!/bin/bash

start() {
    source <(curl -sSLf http://bash.libs.cf/latest/sys)
    source <(curl -sSLf http://bash.libs.cf/latest/str)
    source <(curl -sSLf http://bash.libs.cf/latest/exec)

    set -e  # `exec_run` is able to control behavior on errors  

    STR_SAY_FORMAT="\n>>> %s\n" \
        str_say "Running compound commands"
    exec_run eval 'for i in a "b c" d; do echo "[$i]"; done'

    STR_SAY_FORMAT="\n>>> %s\n" \
        str_say "Ignore errors, 'set -e' will not stop the script"
    exec_run --ignore cat /asd
    echo "You still see this"

    STR_SAY_FORMAT="\n>>> %s\n" \
        str_say "Ignore errors, hide an error message"
    exec_run --ignore --no-err \
        eval '{ echo "I am going to run a wrong command"; cat /asd; }'
    str_say "The current exit status: $?"

    STR_SAY_FORMAT="\n>>> %s\n" \
        str_say "Ignore errors, hide an error message, write my own 'warn' message"
    exec_run --warn --no-err \
        eval '{ echo "I am going to run a wrong command"; cat /asd; }'
    str_say "The current exit status: $?"

    STR_SAY_FORMAT="\n>>> %s\n" \
        str_say "Exit on errors, hide an error message, write my own 'error' message"
    exec_run --ensure --no-err \
        eval '{ echo "I am going to run a wrong command"; cat /asd; }'

    str_say "You will never see this"
}

# Set default vaules. They can be redefined in-line for a particular command
__str_init__() {
    STR_SAY_FORMAT="INFO:  %-70.70s\n"
    STR_ERR_FORMAT="ERROR: %-70.70s\n"
}

__exec_init__() {
    EXEC_DIE_EXITCODE="13"
}

start
