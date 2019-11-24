#!/usr/bin/env roundup

describe "Testing the 'matrix' module..."

before() {
    cd ..
}

after() {
    cd -
}

it_checks_init_destroy() {
    matrix_init my_matrix 1 1 "a"
    declare -p my_matrix &> /dev/null
    matrix_destroy my_matrix
    ! declare -p my_matrix &> /dev/null
}

it_checks_get_set() {
    matrix_init my_matrix 1 1 "a"
    [[ "$(matrix_get my_matrix 0 0)" == "a" ]]

    matrix_set my_matrix 0 0 "z"
    [[ "$(matrix_get my_matrix 0 0)" == "z" ]]
}
