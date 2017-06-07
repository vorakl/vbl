#!/bin/bash

main() {
    source /home/vorakl/repos/my/github/lib-sh/src/common

    say "Hello"
    debug "Saying Hello to the whole World"
    err "No response"
    die "Response timeout. Exiting (status=${DIE_EXITCODE})..."
}

__common_init__() {
    SAY_FORMAT="INFO:  %-70.70s\n"
    ERR_FORMAT="ERROR: %-70.70s\n"
    DEBUG_FORMAT="DEBUG: %-70.70s\n"
    DEBUG_SUPPRESS="0"
    DIE_EXITCODE="13"
}

main
