Installation
############

:slug: installation
:summary: Several ways to install the library

* `General information`_
* `Download a module at run-time using curl`_
* `Download a module by curl and check an integrity by sha256sum`_
* `Download a module using a pure Bash without saving on a disk`_

General information
===================

In general, the installation process looks as follows:

1. Download the ``latest``, ``stable``, or a version of a module from the library.
    The URL of a module's file should be constructed of three parts:
    
    - **The base URL**. It is ``http://vbl.vorakl.com/`` (https is also supported)
    - **The version**. A version can be ``latest/``, ``stable/`` or one 
      of published versions (e.g. ``v2.0.3/``)
    - **The name of a module** (e.g. ``sys``)

    For example:

    - ``http://vbl.vorakl.com/latest/sys``
    - ``http://vbl.vorakl.com/stable/exec``
    - ``http://vbl.vorakl.com/v2.0.3/str``
   
    In addition, each module comes with a sha256 hash (``${module}.sha256``).
    For example, these all are possible URLs of sha256 hashes: 
    
    - ``http://vbl.vorakl.com/latest/exec.sha256``
    - ``http://vbl.vorakl.com/v2.0.2/sys.sha256``

2. Include it into your script.
    Usually, external files with Bash code are included by
    ``source /path/to/file`` or ``. /path/to/file`` instuctions.

There are a few common ways to do these two steps.

|

Download a module at run-time using curl
========================================

This code downloads the latest version of the ``sys`` module and doesn't
save it localy:

.. code-block:: bash

    source <(curl -sSLf http://vbl.vorakl.com/latest/sys)

|

Download a module by curl and check an integrity by sha256sum
=============================================================

This snippet uses two external commands (``curl`` and ``sha256sum``) to download
a module (a version can be also specified), checks its sha256 hash and keeps
everything in memory, without saving a file on a disk. If everything is fine,
then the module will be included. Otherwise, the script exits with an error
message. To simplify things, it's represented as a separate function ``import_lib``:

.. code-block:: bash

    # usage: import_lib lib_name [version]
    import_lib() {
        local _lib_name _ver _lib_content _lib_hash _origlib_hash

        _lib_name="${1?The lib name is empty}"
        [[ -n "$2" ]] && _ver="$2/" || _ver="latest/"
        _lib_content="$(curl -sSLf http://vbl.vorakl.com/${_ver}${_lib_name})"
        _lib_hash="$(set -- $(sha256sum <(echo "${_lib_content}") ); echo "$1")"
        _origlib_hash="$(set -- $(curl -sSLf http://vbl.vorakl.com/${_ver}${_lib_name}.sha256); echo "$1")"
        if [[ "${_lib_hash}" == "${_origlib_hash}" ]]; then
            source <(echo "${_lib_content}")
        else
            echo "The '${_ver}${_lib_name}' module hasn't been loaded" >&2
            exit 1
        fi
    }

This is how it can be used in code:

.. code-block:: bash

    #!/bin/bash

    start() {
        import_lib sys
        # import_lib sys stable

        # add your code here
    }

    import_lib() {
        local _lib_name _ver _lib_content _lib_hash _origlib_hash

        _lib_name="${1?The lib name is empty}"
        [[ -n "$2" ]] && _ver="$2/" || _ver="latest/"
        _lib_content="$(curl -sSLf http://vbl.vorakl.com/${_ver}${_lib_name})"
        _lib_hash="$(set -- $(sha256sum <(echo "${_lib_content}") ); echo "$1")"
        _origlib_hash="$(set -- $(curl -sSLf http://vbl.vorakl.com/${_ver}${_lib_name}.sha256); echo "$1")"
        if [[ "${_lib_hash}" == "${_origlib_hash}" ]]; then
            source <(echo "${_lib_content}")
        else
            echo "The '${_ver}${_lib_name}' module hasn't been loaded" >&2
            exit 1
        fi
    }

    start "$@"

|

Download a module using a pure Bash without saving on a disk
============================================================

This one is quite tricky. For downloading a module it doesn't use any external
tools, such as ``curl`` or ``wget``, just a pure Bash code. It also doesn't
store a file on a disk:

.. code-block:: bash

    lib_name="latest/sys" 
    source <(
        exec 3<>/dev/tcp/vbl.vorakl.com/80
        printf "GET /${lib_name} HTTP/1.1\nHost: vbl.vorakl.com\nConnection: close\n\n" >&3
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

or in a shorter form, as a one-liner:

.. code-block:: bash

   lib_name="latest/sys"; source <(exec 3<>/dev/tcp/vbl.vorakl.com/80; printf "GET /${lib_name} HTTP/1.1\nHost: vbl.vorakl.com\nConnection: close\n\n" >&3; body=0; while IFS= read -u 3 -r str; do if (( body )); then printf "%s\n" "${str}"; else [[ -z "${str%$'\r'}" ]] && body=1; fi done; exec 3>&-)

This is the example of how the snippet can be used in code:

.. code-block:: bash

    #!/bin/bash

    start() {
        lib_name="latest/sys"
        source <(exec 3<>/dev/tcp/vbl.vorakl.com/80; printf "GET /${lib_name} HTTP/1.1\nHost: vbl.vorakl.com\nConnection: close\n\n" >&3; body=0; while IFS= read -u 3 -r str; do if (( body )); then printf "%s\n" "${str}"; else [[ -z "${str%$'\r'}" ]] && body=1; fi done; exec 3>&-)

    start "$@"

