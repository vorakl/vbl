#!/bin/bash

main() {
    source <(curl -sSLf http://bash.libs.cf/latest/common)

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
