#!/bin/bash

main() {
    # Download and include the common library each time at run-time without saving on a disk
    source <(
        exec 3<>/dev/tcp/lib-sh.vorakl.name/80
        printf "GET /files/common HTTP/1.1\nHost: lib-sh.vorakl.name\nConnection: close\n\n" >&3
        body=0; 
        while IFS= read -u 3 -r str; do 
            if (( body )); then 
                printf "%s\n" "${str}"
            else 
                [[ -z "${str%$'\r'}" ]] && body=1
            fi
        done
        exec 3>&-
    )

    say "Usage:   $0 command arg ..."
    say "Example: $0 ls -l /"
    say "         $0 ls -l /nonexistent"
    say "\nI'm about to run '$*'"

    run --warn --save-out output --save-err errors "$@"

    say "\nStdOut:"
    say "${output}"

    say "\nStdErr:"
    say "${errors}"
}

__common_init__() {
    SAY_FORMAT="%b\n"
}

main "$@"
