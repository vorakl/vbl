#!/usr/bin/env roundup

describe "Testing the 'str' module..."

before() {
    cd ..
}

after() {
    cd -
}

it_checks_say() {
    output="$(STR_SAY_FORMAT="%10.8s" str_say "Hello World")"
    [[ "${output}" == "  Hello Wo" ]]
}

it_checks_debug() {
    output="$(STR_DEBUG_SUPPRESS="0" STR_DEBUG_FORMAT="DEBUG: [%s]" \
              str_debug "This is the Debug!")"
    [[ "${output}" == "DEBUG: [This is the Debug!]" ]]
}

it_checks_err() {
    output1="$(STR_ERR_FORMAT="ERROR: (%s)" str_err "This is the Error!")"
    [[ -z "${output1}" ]]

    # stderr also contains debug output, so, it needs to be matched via a regexp
    output2="$(STR_ERR_FORMAT="ERROR: (%s)" str_err "hiddenError" 2>&1)"
    [[ ${output2} =~ "hiddenError" ]]
}

it_checks_readline() {
    text="Hello"$'\n'"World"
    output="$(echo -n "${text}" | while str_readline str; do echo "${str}"; done)"
    [[ "${output}" == "Hello"$'\n'"World" ]]
}

it_checks_readlines() {
    text="Hello"$'\n'"World"
    output=$(str_readlines output <<< "${text}"; echo "${output[1]}")
    [[ "${output}" == "World" ]]
}

it_checks_format() {
    output1="$(echo -n "Hello" | str_format "...%s...")"
    [[ "${output1}" == "...Hello..." ]]

    output2="$(str_format "%05d" - 12)"
    [[ "${output2}" == "00012" ]]

    str_format "%+05d" output3 "-123"
    [[ "${output3}" == "-0123" ]]
}

it_checks_rstrip() {
    output1="$(printf "Hello\n\n\n" | str_rstrip)"
    [[ "${output1}" == "Hello" ]]

    output2="$(echo -n "Hello...." | str_rstrip ".")"
    [[ "${output2}" == "Hello" ]]

    output3=$(str_rstrip "." output < <( echo -n "Hi..."); echo -n "${output}")
    [[ "${output3}" == "Hi" ]]
}

it_checks_lstrip() {
    output1="$(echo -n "    Hello" | str_lstrip)"
    [[ "${output1}" == "Hello" ]]

    output2="$(echo -n ".....Hello" | str_lstrip ".")"
    [[ "${output2}" == "Hello" ]]

    output3=$(str_lstrip "." output < <( echo -n "....Hi"); echo -n "${output}")
    [[ "${output3}" == "Hi" ]]
}

it_checks_strip() {
    output1="$(echo -n "     Hello   " | str_strip)"
    [[ "${output1}" == "Hello" ]]

    output2="$(echo -n "....Hello......." | str_strip ".")"
    [[ "${output2}" == "Hello" ]]

    output3=$(str_strip "." out < <( echo -n "..Hi...."); echo -n "${out}")
    [[ "${output3}" == "Hi" ]]
}

