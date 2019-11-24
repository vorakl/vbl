#!/usr/bin/env roundup

describe "Testing the 'sys' module..."

before() {
    cd ..
}

after() {
    cd -
}

it_checks_cmd() {
    sys_cmd -v bash
}

it_checks_cmd_is_exported() {
    bash -c 'declare -pF sys_cmd'
}
