#!/bin/bash

__common_init__() {
    say_format="INFO:  %-70.70s\n"
    err_format="ERROR: %-70.70s\n"
    debug_format="DEBUG: %-70.70s\n"
    debug_suppress="0"
    die_exitcode="13"
}
source /home/vorakl/repos/my/github/lib-sh/common


say "Hello"
debug "Saying Hello to the whole World"
err "No response"
die "Response timeout. Exiting (status=${die_exitcode})..."
