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
    output="$(run eval '{ say "Hello"; err "World"; }')"
    [[ "${output}" == "Hello" ]]

    output="$(run --no-out eval '{ say "Hello"; err "World"; }')"
    [[ -z "${output}" ]]
}

it_checks_run_output_stderr() {
    set +x
    output="$(run err "Error" 2>&1)"
    [[ "${output}" == "Error" ]]

    output="$(run --no-err err "Error" 2>&1)"
    [[ -z "${output}" ]]
}

it_checks_run_output_join() {
    set +x
    output="$(run --join-outerr eval '{ SAY_FORMAT="%s" say "Hello "; err "World"; }')"
    [[ "${output}" == "Hello World" ]]
}

it_checks_run_output_silent() {
    set +x
    output="$(run --silent eval '{ say "Hello "; err "World"; }' 2>&1)"
    [[ -z "${output}" ]]
}

it_checks_run_output_save() {
    set +x
    run --save-out my_out --save-err my_err eval '{ say "Hello"; err "World"; }'
    [[ "${my_out/$'\n'/}" == "Hello" ]]
    [[ "${my_err/$'\n'/}" == "World" ]]
}

it_checks_run_status_ignore() {
    run --ignore false
}

it_checks_run_status_warn() {
    set +x
    output="$(RUN_WARN_FORMAT="%s-%d\n" run --warn --no-err cat /nonexistent 2>&1)"
    [[ "${output}" == "cat-1" ]]
}

it_checks_run_status_ensure() {
    set +x
    if output="$(DIE_EXITCODE=14; RUN_ENSURE_FORMAT="%s-%d-%d\n" run --ensure --no-err cat /nonexistent 2>&1)"
    then
        echo "This test does not work"
        return 1
    else
        [[ "${output}" == "cat-1-14" ]]
    fi
}

it_checks_readline() {
    text="Hello"$'\n'"World"
    output="$(echo -n "${text}" | while IFS= read -r str; do echo "${str}"; done)"
    [[ "${output}" == "Hello" ]]

    output="$(echo -n "${text}" | while IFS= readline -r str; do echo "${str}"; done)"
    [[ "${output}" == "Hello"$'\n'"World" ]]
}
