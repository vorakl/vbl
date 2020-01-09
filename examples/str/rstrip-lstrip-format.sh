#!/bin/bash

start() {
    source <(curl -sSLf http://vbl.vorakl.com/latest/sys)
    source <(curl -sSLf http://vbl.vorakl.com/latest/str)

    echo -n "Hello..." | str_rstrip "."
    echo

    echo "Hello..." | str_rstrip | str_rstrip "."
    echo

    { str_rstrip | str_strip | str_format "[%s]\n"; } <<< "     Hello      "

    str_rstrip "." out < <( echo -n "Hello....")
    echo "${out}"

    str_lstrip <<< "   Hello"

    str_lstrip "." out < <(echo -n ".....Hello")
    echo "${out}"

    date '+%s' | str_rstrip | str_format "The current time: %(%H:%M:%S)T\n"

    str_format "%14.2f" out "1.48732599"
    echo "A formated digit \"1.48732599\": \"${out}\""

    str_format "Another formated digit: %08.2f\n" - "-1.33867"

    printf "Hello\nWorld" | str_format "[%s]\n"

    str_format "Here is only first line because all lines in the file end with NULL:\n%s\n" < /proc/$$/environ
}

start
