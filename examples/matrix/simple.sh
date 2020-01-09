#!/bin/bash

start() {
    source <(curl -sSLf http://vbl.vorakl.com/latest/sys)
    source <(curl -sSLf http://vbl.vorakl.com/latest/str)
    source <(curl -sSLf http://vbl.vorakl.com/latest/matrix)

    matrix_init my_matrix \
               3 2 \
               one two three \
               "1 1" "2 2" "3 3"
    matrix_get my_matrix 1 1
    matrix_set my_matrix 1 1 "4 4 4"
    matrix_get my_matrix 1 1
    matrix_destroy my_matrix
}

start
