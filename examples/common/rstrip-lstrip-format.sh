#!/bin/bash

main() {
    source <(curl -sSLf http://lib-sh.vorakl.name/files/common)

    readlines -r out < <(date)
    printf "\nRaw results:\n"
    printf "($out)\n"

    rstrip $'\n' out <<< "$out"
    printf "\nStrip new line at the end:\n"
    printf "($out)\n"


    printf "\nAdd extra symbols \"........\"\n"
    date | rstrip $'\n' | format "(%s.......)\n"
    date | rstrip $'\n' | format "%s.......\n" | rstrip "." out
    printf "\nStrip \"........\" from the right\n"
    printf "($out)\n"

    date '+%s' | rstrip $'\n' | format "\nThe current time: %(%H:%M:%S)T\n"

    format "%14.2f" out "1.4899999"
    printf "\nA formated digit \"1.4899999\": (${out})\n"

    format "\nAnother formated digit: %08.2f\n" - "-1.34567"

    str="        Hello"
    lstrip " " out <<< "${str}"
    printf "\nThe raw string (${str})\n"
    printf "Strip spaces from the left (${out})\n"
}

main
