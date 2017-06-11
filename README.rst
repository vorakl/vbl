A collection of Bash libraries
##############################

* Introduction_
* Installation_
    * `Download using wget without saving on a disk`_
    * `Download using curl and Check an integrity by sha256sum tool`_
    * `Download using a pure Bash code without saving on a disk`_
* `The list of libraries`_

Introduction
============

Bash is a powerful programming language and very useful for operational tasks. Without any doubts, this is the first "tool" you use in system administering of Unix-like operating systems. Unfortunately, it doesn't have a "Standard library" with all that functions which make a development process easier, faster and more efficient in all senses.

Suddenly, I realized that I use the same functions, same blocks of code everywhere. Apparently, copy-pasting them from one script to another is not a right approach. That's why I decided to organize the most used functions in a few libraries and place them on a publicly available resource over http. This makes possible to find all needed files in one place, download them using simple tools or even a pure Bash code, always download the latest version of each library or even get stuck to a specific version in terms of stability and reliability.

Basically, for me use these functions helps to

* reuse the same code everywhere which is checked and proved by the time
* simplify and speed up a development
* increase a readability of code

Besides all mentioned benefits, I would recommend to spend a little time and dig into the code to get a full understanding of how it works. Actually, this is a good practice before using any kind of libraries or functions.


Installation
============

In general, the installation process looks as follows:

1. Download the latest version of a library from this collection.
2. Include it into your script.

These are just a few possible examples of how ito do that.

Download using wget without saving on a disk
--------------------------------------------

This code downloads the 'common' library from the Internet on each run and doesn't save it in any file,

.. code-block:: bash

    #!/bin/bash

    main() {
        source <(wget -qO - http://lib-sh.vorakl.name/files/common)

        # your code
    }

    main "$@"


Download using curl and Check an integrity by sha256sum tool
-------------------------------------------------------------------

This example downloads the library, saves it in a working directory with the original name. If it's happened, then a trap for deleting this file on exit is being set. Then, a correct sha256 hash is downloaded and checked an integrity. If everything is fine, then the library is included. Otherwise, the script exits with an error message.

.. code-block:: bash

    #!/bin/bash

    main() {
        curl -sSLfo common http://lib-sh.vorakl.name/files/common && \
        trap 'rm -f common' EXIT TERM HUP INT && \
        curl -sSLf http://lib-sh.vorakl.name/files/common.sha256 | sha256sum --quiet -c && \
        source common || \
        { echo "The library hasn't been loaded" >&2; exit 1; }

        # your code
    }

    main "$@"


Download using a pure Bash code without saving on a disk
--------------------------------------------------------

This example is a little bit more complicated. For downloading files it doesn't use any external tools, just a pure Bash code. Then, it shows how to configure a behaviour of functions from the lib by defining ``__common_init__()`` function, how to do a formated printing nad how to run command under a wrapper to control exit status and save stdout/stderr separately in variables. 

.. code-block:: bash

    #!/bin/bash

    main() {
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


The list of libraries
=====================

* common_, the library with often used functions

.. Links

.. _common: https://github.com/vorakl/lib-sh/blob/master/common.rst 
