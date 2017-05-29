#!/bin/bash

__common_init__() {
    # Set default vaules. They can be redefined in-line for a particular command
    say_format="INFO:  %-70.70s\n"
    err_format="ERROR: %-70.70s\n"
}
source /home/vorakl/repos/my/github/lib-sh/common


say_format="\n>>> %s\n" say "Stdout goes to the pipe, stderr goes to the terminal"
run eval '{ say "hello"; err "world"; }' | { a=$(cat); echo "[$a]"; }

say_format="\n>>> %s\n" say "Stdout is suppressed, stderr goes to the terminal"
run --no-out eval '{ say "hello"; err "world"; }' | { a=$(cat); echo "[$a]"; }

say_format="\n>>> %s\n" say "Stdout goes to the pipe, stderr is suppressed"
run --no-err eval '{ say "hello"; err "world"; }' | { a=$(cat); echo "[$a]"; }

say_format="\n>>> %s\n" say "Both streams go to the pipe"
run --join-outerr eval '{ say "hello"; err "world"; }' | { a=$(cat); echo "[$a]"; }

say_format="\n>>> %s\n" say "Both streams are suppressed"
run --silent eval '{ say "hello"; err "world"; }' | { a=$(cat); echo "[$a]"; }

