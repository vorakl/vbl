#!/bin/bash

main() {
    source <(curl -sSLf http://bash.libs.cf/latest/common)

    echo -n "Hello..." | rstrip "."
    echo

    echo "Hello..." | rstrip $'\n' | rstrip "."
    echo

    { rstrip $'\n' | rstrip "."; } <<< "Hello...."
    echo

    rstrip "." out < <( echo -n "Hello....")
    echo "${out}"

    lstrip " " <<< "   Hello"

    lstrip "." out < <( echo -n ".....Hello")
    echo "${out}"

    date '+%s' | rstrip $'\n' | format "The current time: %(%H:%M:%S)T\n"

    format "%14.2f" out "1.48732599"
    echo "A formated digit \"1.48732599\": \"${out}\""

    format "Another formated digit: %08.2f\n" - "-1.33867"

    printf "Hello\nWorld" | format "[%s]\n"

    format "Here is only first line because lines in the file end by NULL:\n%s\n" < /proc/$$/environ
}

main
