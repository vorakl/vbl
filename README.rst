A collection of Bash libraries
##############################

* Introduction_
* Installation_
    * `Download the latest version using curl or wget without saving on a disk`_
    * `Download the latest common lib using curl and Check an integrity by sha256sum tool`_
    * `Download the latest common using a pure Bash code without saving on a disk`_
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
    The URL to a file can be constructed from three parts by gluing them together: 
    
    - The base URL: ``http://lib-sh.vorakl.name/files/``
    - A version. This is optional and if it's not specified, then the latest version will be requested. Basically, it follows the `Semantic Versioning`_, e.g. v1.2.3 
    - The name of a library: it's exactly the same name as in `The list of libraries`_

    For example:

    - ``http://lib-sh.vorakl.name/files/common``, the ``common`` library and the latest version.
    - ``http://lib-sh.vorakl.name/files/v1.0.4/common``, the ``common`` library and it's always a v1.0.4 version.
   

2. Include it into your script.
    Usually, external files with Bash code are included by ``source /path/to/file`` or ``. /path/to/file`` instuctions.


These are just a few possible examples of how to do that.

Download the latest version using curl or wget without saving on a disk
-----------------------------------------------------------------------

This code downloads the ``common`` library from the Internet on each run and doesn't save it in any file.
Usually, this snippet needs to be added some where in the beggining of a bash script.

.. code-block:: bash

    source <(curl -sSLf http://lib-sh.vorakl.name/files/common)

or

.. code-block:: bash

    source <(wget -qO - http://lib-sh.vorakl.name/files/common)

For instance, it can be used as following

.. code-block:: bash

    #!/bin/bash

    main() {
        source <(curl -sSL fhttp://lib-sh.vorakl.name/files/common)

        # add your code here
    }

    main "$@"


Download the latest common lib using curl and Check an integrity by sha256sum tool
----------------------------------------------------------------------------------

This snippet downloads the library, saves it in a working directory with the original name. Then, a correct sha256 hash is downloaded and an integrity is checked. If everything is fine, then the library is included. Otherwise, the script exits with an error message. 

.. code-block:: bash

        curl -sSLfo common http://lib-sh.vorakl.name/files/common && \
        curl -sSLf http://lib-sh.vorakl.name/files/common.sha256 | sha256sum --quiet -c && \
        source common || \
        { echo "The library hasn't been loaded" >&2; exit 1; }

For instance, it can be used as following

.. code-block:: bash

    #!/bin/bash

    main() {
        curl -sSLfo common http://lib-sh.vorakl.name/files/common && \
        curl -sSLf http://lib-sh.vorakl.name/files/common.sha256 | sha256sum --quiet -c && \
        source common || \
        { echo "The library hasn't been loaded" >&2; exit 1; }

        # add your code here
    }

    main "$@"


Download the latest common using a pure Bash code without saving on a disk
--------------------------------------------------------------------------

For downloading the library this snippet doesn't use any external tools, just a pure Bash code.

.. code-block:: bash

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

This is the example of how the snippet can be used. In addition, it shows how to configure a behaviour of functions from the library by defining ``__common_init__()`` function, how to do a formated printing and how to run a command under the wrapper for controling an exit status and save stdout/stderr separately in variables. 

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
.. _`Semantic Versioning`: http://semver.org/
