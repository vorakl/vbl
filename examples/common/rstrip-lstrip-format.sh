#!/bin/bash

main() {
    source /home/vorakl/repos/my/github/lib-sh/src/common

    readlines -r out < <(date)
    printf "\nRaw results:\n"
    printf "($out)\n"

    rstrip $'\n' out <<< "$out"
    printf "\nStrip new line at the end:\n"
    printf "($out)\n"


    printf "\nAdd extra symbols \"........\"\n"
    date | format "(%s.......)\n"
    date | format "%s.......\n" | rstrip "." out
    printf "\nStrip \"........\" from the right\n"
    printf "($out)\n"

    date '+%s' | format "\nThe current time: %(%H:%M:%S)T\n"

    format "%14.2f" out <<< "1.4899999"
    printf "\nA formated digit \"1.4899999\": (${out})\n"

    str="        Hello"
    lstrip " " out <<< "${str}"
    printf "\nThe raw string (${str})\n"
    printf "Strip spaces from the left (${out})\n"
}

main
