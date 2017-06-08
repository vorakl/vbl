A collection of Bash libraries
##############################

An each library from this set collects many useful functions for simplifying a development in Bash.
Instead of copy/pasting the same functions from one script to another it's much better to include once an external library and reuse the same code everywhere.

* Installation_
* `Quick start`_
    * `Download using wget without saving on a disk`_
    * `Download using curl and Check an integrity by comparing sha256 hash`_
    * `Download using a pure Bash code without saving on a disk`_
* `The list of libraries`_


Installation
============

In general, the installation process looks as follows:

1. Download the latest version of a library from this collection
2. Include it into your script.

Quick start
===========

These are just a few possible examples of how you can download and include libs from the remote resource.

Download using wget without saving on a disk
--------------------------------------------

This code downloads the common library on each run, reads all lines ended by ``\0``, saves them all in one variable as normal lines (ended by ``\n``) and then prints to the stdout

.. code-block:: bash

    #!/bin/bash

    main() {
        source <(wget -qO - http://lib-sh.vorakl.name/files/common)

        readlines -r -d '' envs < /proc/$$/environ
        echo -n "${envs}"
    }

    main


Download using curl and Check an integrity by comparing sha256 hash
-------------------------------------------------------------------

This example downloads the lib and sets a trap on success for deleting the file on exit. Then, it downloads a correct sha256 hash and checks an integrity of the lib. if everything is fine, it could download and save a file, check an integrity, then it reads in a loop strings which are ended by ``\0`` and prints them out using a specified format.

.. code-block:: bash

    #!/bin/bash

    main() {
        curl -sSLfo common http://lib-sh.vorakl.name/files/common && \
        trap 'rm -f common' EXIT TERM HUP INT && \
        curl -sSLf http://lib-sh.vorakl.name/files/common.sha256 | sha256sum --quiet -c && \
        source common || \
        { echo "The library hasn't been loaded" >&2; exit 1; }

        local _envs="" _i="0"

        while ((++_i)); readline -r -d '' _envs; do
            echo "${_envs}" | format "env ${_i}: %s"
        done < /proc/$$/environ
    }

    main


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
