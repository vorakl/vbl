#!/usr/bin/env roundup

describe "Test of the common library"

before() {
    cd ..
}

after() {
    cd -
}

it_checks_say() {
    output="$(SAY_FORMAT="%10.8s" say "Hello World")"
    [[ "${output}" == "  Hello Wo" ]]
}

it_checks_debug() {
    output="$(DEBUG_SUPPRESS="0" DEBUG_FORMAT="DEBUG: [%s]" debug "This is the Debug!")"
    [[ "${output}" == "DEBUG: [This is the Debug!]" ]]
}

it_checks_err() {
    set +x
    output="$(ERR_FORMAT="ERROR: (%s)" err "This is the Error!")"
    [[ -z "${output}" ]]

    output="$(ERR_FORMAT="ERROR: (%s)" err "This is the Error!" 2>&1)"
    [[ "${output}" == "ERROR: (This is the Error!)" ]]
}

it_checks_die() {
    if (DIE_EXITCODE=13; die "Have a nice day")
    then
        echo "This test does not work"
        return 1
    else
        (( $? == 13 ))
    fi
}

it_checks_cmd() {
    cmd -v bash
}

it_checks_run_output_stdout() {
    output="$(run eval '{ say "hello"; err "world"; }')"
    [[ "${output}" == "hello" ]]

    output="$(run --no-out eval '{ say "hello"; err "world"; }')"
    [[ -z "${output}" ]]
}

it_checks_run_output_stderr() {
    set +x
    output="$(run err "error" 2>&1)"
    [[ "${output}" == "error" ]]

    output="$(run --no-err err "error" 2>&1)"
    [[ -z "${output}" ]]
}

it_checks_run_output_join() {
    set +x
    output="$(run --join-outerr eval '{ SAY_FORMAT="%s" say "hello "; err "world"; }')"
    [[ "${output}" == "hello world" ]]
}

it_checks_run_output_silent() {
    set +x
    output="$(run --silent eval '{ SAY_FORMAT="%s" say "hello "; err "world"; }' 2>&1)"
    [[ -z "${output}" ]]
}

