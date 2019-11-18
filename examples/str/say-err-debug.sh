#!/bin/bash

start() {
    source <(curl -sSLf http://bash.libs.cf/latest/sys)
    source <(curl -sSLf http://bash.libs.cf/latest/str)

    str_say "Hello World"
    STR_SAY_FORMAT="INFO [%s]: %s\n" str_say "main" "Loading to memory..."

    str_debug "Saying Hello to the whole World"
    STR_DEBUG_SUPPRESS=0 STR_DEBUG_FORMAT="DEBUG: %s\n" \
         str_debug "The queue is empty"

    str_err "No response"
    STR_ERR_FORMAT="WARN: %s\n" str_err "too much arguments"
}

__str_init__() {
    STR_SAY_FORMAT="INFO:  %-70.70s\n"
    STR_ERR_FORMAT="ERROR: %-70.70s\n"
    STR_DEBUG_FORMAT="DEBUG: %-70.70s\n"
    STR_DEBUG_SUPPRESS="0"
}

start
