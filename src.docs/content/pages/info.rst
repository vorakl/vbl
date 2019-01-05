A collection of Bash libraries
##############################

:slug: info
:summary: A collection of Bash libraries

|build-status|

* Introduction_
* `The list of libraries`_
* Installation_
    * `The simplest one-liner which uses curl/wget to dowload a file without saving on a disk`_
    * `Download a library by curl and check an integrity by sha256sum`_
    * `Download a library using a pure Bash without saving on a disk`_
* `How to reconfigure the functions`_


Introduction
============

Bash is a powerful programming language and very useful for operational tasks. Without any doubts, this is the first "tool" you use in system administering of Unix-like operating systems. Unfortunately, it doesn't have a "Standard library" with all that functions which make a development process easier, faster and more efficient in all senses.

Suddenly, I realized that I use the same functions, same blocks of code everywhere. Apparently, copy-pasting them from one script to another is not a right approach. That's why I decided to organize the most used functions in a few libraries and place them on a publicly available resource over http. This makes possible to find all needed files in one place, download them using simple tools or even a pure Bash code, always download the latest version of each library or even get stuck to a specific version in terms of stability and reliability.

Basically, for me use these functions helps to

* reuse the same code everywhere which is checked and proved by the time
* simplify and speed up a development
* increase a readability of code

Besides all mentioned benefits, I would recommend to spend a little time and dig into the code to get a full understanding of how it works. Actually, this is a good practice before using any kind of libraries or functions.


The list of libraries
=====================

* common_, the library with often used functions


Installation
============

In general, the installation process looks as follows:

1. Download the latest version of a library from this collection.
    The URL to a library's file should be constructed from three parts by gluing them together: 
    
    - **The base URL**. It is ``http://bash.libs.cf/files/``
    - **The version**. The list of all available versions is `here`__. This is optional and if it's not specified, then the latest version will be requested. Basically, it follows the `Semantic Versioning`_, e.g. v1.2.3 
    - **The name of a library**. It's exactly the same name as in `The list of libraries`_

    __ https://github.com/vorakl/bash-libs/releases

    For example:

    - ``http://bash.libs.cf/files/common``, for the ``common`` library and the latest version.
    - ``http://bash.libs.cf/files/v1.0.4/common``, for the ``common`` library and the v1.0.4 version.
   
    In addition, each library comes with a sha256 hash. A file name for it looks like ${LIBNAME}.sha256
    For example, these are URLs for a sha256 hashes of the ``common`` library: 
    
    - ``http://bash.libs.cf/files/common.sha256``
    - ``http://bash.libs.cf/files/v1.0.4/common.sha256``

2. Include it into your script.
    Usually, external files with Bash code are included by ``source /path/to/file`` or ``. /path/to/file`` instuctions.


There are plenty of ways to do these two steps.
I'm gonna show just a few examples of how to download and include a library to some bash script.


The simplest one-liner which uses curl/wget to dowload a file without saving on a disk
--------------------------------------------------------------------------------------

This code downloads the ``common`` library from the remote resource on each run and doesn't save it in any file.
Usually, this snippet needs to be added some where in the begining of a bash script.

.. code-block:: bash

    lib_name="common"; source <(curl -sSLf http://bash.libs.cf/files/${lib_name})

or

.. code-block:: bash

    lib_name="v1.0.4/common"; . <(wget -qO - http://bash.libs.cf/files/${lib_name})

For instance, it can be used as follows:

.. code-block:: bash

    #!/bin/bash

    main() {
        lib_name="common"
        source <(curl -sSLf http://bash.libs.cf/files/${lib_name})

        # add your code here
    }

    main "$@"


Download a library by curl and check an integrity by sha256sum
--------------------------------------------------------------

This snippet uses two external commands (``curl`` and ``sha256sum``) to download a library (a version can be also specified), checks its sha256 hash and keeps everything in memory, without saving files on a disk. If everything is fine, then the library is included. Otherwise, the script exits with an error message. To simplify things, it's represented as a separate function ``import_lib``:

.. code-block:: bash

    # usage: import_lib lib_name [version]
    import_lib() {
        local _lib_name _ver _lib_content _lib_hash _origlib_hash

        _lib_name="${1?The lib name is empty}"
        [[ -n "$2" ]] && _ver="$2/" || _ver=""
        _lib_content="$(curl -sSLf http://bash.libs.cf/files/${_ver}${_lib_name})"
        _lib_hash="$(set -- $(sha256sum <(echo "${_lib_content}") ); echo "$1")"
        _origlib_hash="$(set -- $(curl -sSLf http://bash.libs.cf/files/${_ver}${_lib_name}.sha256); echo "$1")"
        if [[ "${_lib_hash}" == "${_origlib_hash}" ]]; then
            source <(echo "${_lib_content}")
        else
            echo "The '${_ver}${_lib_name}' library hasn't been loaded" >&2
            exit 1
        fi
    }

This is how it can be used:

.. code-block:: bash

    #!/bin/bash

    main() {
        import_lib common
        # import_lib common v1.0.4

        # add your code here
    }

    import_lib() {
        local _lib_name _ver _lib_content _lib_hash _origlib_hash

        _lib_name="${1?The lib name is empty}"
        [[ -n "$2" ]] && _ver="$2/" || _ver=""
        _lib_content="$(curl -sSLf http://bash.libs.cf/files/${_ver}${_lib_name})"
        _lib_hash="$(set -- $(sha256sum <(echo "${_lib_content}") ); echo "$1")"
        _origlib_hash="$(set -- $(curl -sSLf http://bash.libs.cf/files/${_ver}${_lib_name}.sha256); echo "$1")"
        if [[ "${_lib_hash}" == "${_origlib_hash}" ]]; then
            source <(echo "${_lib_content}")
        else
            echo "The '${_ver}${_lib_name}' library hasn't been loaded" >&2
            exit 1
        fi
    }

    main "$@"


Download a library using a pure Bash without saving on a disk
-------------------------------------------------------------

This one is quite interesting. For downloading a library it doesn't use any external commands like ``curl`` or ``wget``, just a pure Bash code. It also doesn't store a file on a disk.

.. code-block:: bash

    lib_name="v1.0.4/common" 
    source <(
        exec 3<>/dev/tcp/bash.libs.cf/80
        printf "GET /files/${lib_name} HTTP/1.1\nHost: bash.libs.cf\nConnection: close\n\n" >&3
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

or in a shorter form, as a one-liner

.. code-block:: bash

   lib_name="common"; source <(exec 3<>/dev/tcp/bash.libs.cf/80; printf "GET /files/${lib_name} HTTP/1.1\nHost: bash.libs.cf\nConnection: close\n\n" >&3; body=0; while IFS= read -u 3 -r str; do if (( body )); then printf "%s\n" "${str}"; else [[ -z "${str%$'\r'}" ]] && body=1; fi done; exec 3>&-)


This is the example of how the snippet can be used. In addition, it shows how to configure a behaviour of functions from the library by defining ``__common_init__()`` function, how to do a formated printing and how to run a command under the wrapper for controling an exit status and save stdout/stderr separately in variables. 

.. code-block:: bash

    #!/bin/bash

    main() {
        lib_name="common"
        source <(exec 3<>/dev/tcp/bash.libs.cf/80; printf "GET /files/${lib_name} HTTP/1.1\nHost: bash.libs.cf\nConnection: close\n\n" >&3; body=0; while IFS= read -u 3 -r str; do if (( body )); then printf "%s\n" "${str}"; else [[ -z "${str%$'\r'}" ]] && body=1; fi done; exec 3>&-)

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


How to reconfigure the functions
================================

Many functions in libraries can be reconfigured at run-time by setting appropriate parameters. All available for changing parameters can be found in the description to a function. This allows to use the same code everywhere and change a function's behavior (e.g. messages format, exit codes) for a particular need. It's possible to do either at global scope by setting them once in the beginning of a script (example1_) or in-line to modify a specific call (example2_). 

It works as follows. Every library has an entrypoint, a function which is called like ``__${LIB}_main__``. It's executed automaticaly when a library is included. In the next step, ``__${LIB}_conf__`` is executed which runs all available ``__${FUNC}_conf__`` functions for for setting default values. Then, ``__${LIB}_main__`` checks if the ``__${LIB}_init__`` function has been previosly defined (in a script which includes a library). If so, it's also executed. This is exactly the function where all needed parameters should be redefined. In the last step, the ``__${LIB}_export__`` function is executed to export all functions which are mentioned in the ``__${LIB}_export`` variable. This variable, actually, can be also redefined in the ``__${LIB}_init__`` function. By changing the ``__${LIB}_export`` variable, you can controll which functions will be available only in the script and which in all sub-processes.

.. code-block:: bash

    #!/bin/bash

    main() {
        lib_name="common"
        source <(exec 3<>/dev/tcp/bash.libs.cf/80; printf "GET /files/${lib_name} HTTP/1.1\nHost: bash.libs.cf\nConnection: close\n\n" >&3; body=0; while IFS= read -u 3 -r str; do if (( body )); then printf "%s\n" "${str}"; else [[ -z "${str%$'\r'}" ]] && body=1; fi done; exec 3>&-)

        say "The 'say' function works in this script..."
        bash -c say "... and doesn't work in a sub-processes because it wasn't exported"
    }

    __common_init__() {
        __common_export="cmd run"
    }

    main "$@"


.. Links

.. _common: /pages/common/
.. _`Semantic Versioning`: http://semver.org/
.. _example1: https://github.com/vorakl/bash-libs/blob/master/examples/common/say-err-debug.sh
.. _example2: https://github.com/vorakl/bash-libs/blob/master/examples/common/run-output.sh
.. |build-status| image:: https://travis-ci.org/vorakl/bash-libs.svg?branch=master
   :target: https://travis-ci.org/vorakl/bash-libs
   :alt: Travis CI: continuous integration status
