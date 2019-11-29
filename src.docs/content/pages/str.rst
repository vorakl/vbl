str
###

:slug: str
:summary: Functions for strings processing


API
===

* `__str_version`_ <var>
* `__str_exported`_ <var>
* STR_SAY_SUPPRESS <var>
* STR_SAY_FORMAT <var>
* STR_DEBUG_SUPPRESS <var>
* STR_DEBUG_FORMAT <var>
* STR_ERR_SUPPRESS <var>
* STR_ERR_FORMAT <var>
* `__str_init__`_ <func>
* str_say_ <func>
* str_debug_ <func>
* str_err_ <func>
* str_readline_ <func>
* str_readlines_ <func>
* str_format_ <func>
* str_rstrip_ <func>
* str_lstrip_ <func>
* str_strip_ <func>

|

REQIRES
=======

* sys

|

USAGE
=====

    source module_name [list of functions to export]

By default, all functions are exported, so they can be used in sub-shells.
It is also possible to specify which functions should be exported when a module
is loaded by defining them as a list in the **'source'** command or in the
`__str_exported`_ variable.

example:
--------

    .. code-block:: bash

        #!/bin/bash

        start() {
            source <(curl -sSLf http://bash.libs.cf/latest/sys)
            source <(curl -sSLf http://bash.libs.cf/latest/str) str_say str_err
        }

        start

|

__str_version
=============

This readonly variable contains a current module's version.

|

__str_exported
==============

This variable contains a list (separated by a space symbol) of functions that
will be exported. It can be altered in the `__str_init__`_ function.

|

__str_init__
============

This function has to be defined before the module is imported.
It can be used for setting up default values for any function's variables.

example:
--------

    .. code-block:: bash

        #!/bin/bash

        __str_init__() {
            __str_exported="str_say str_err str_debug"
        }

        start() {
            source <(curl -sSLf http://bash.libs.cf/latest/sys)
            source <(curl -sSLf http://bash.libs.cf/latest/str)
        }

        start

|

str_say
=======

Prints to the STDOUT with an ability to set a format.

usage:
------

    **str_say** arg [...]

options:
--------

    - *STR_SAY_SUPPRESS*, default is "0"
    - *STR_SAY_FORMAT*, default is "%s\n" 

examples:
---------

    .. code-block:: bash

        #!/bin/bash

        __str_init__() {
            STR_SAY_FORMAT="[INFO]: %s\n"
        }

        start() {
            source <(curl -sSLf http://bash.libs.cf/latest/sys)
            source <(curl -sSLf http://bash.libs.cf/latest/str)

            str_say "Hello World"
        }

        start

    .. code-block:: bash

        #!/bin/bash

        start() {
            source <(curl -sSLf http://bash.libs.cf/latest/sys)
            source <(curl -sSLf http://bash.libs.cf/latest/str)

            STR_SAY_FORMAT="INFO [%s]: %s\n" \
                str_say "main" "Loading to memory..."
        }

        start

|

str_debug
=========

Prints to the STDOUT as **'say'** does but only if STR_DEBUG_SUPPRESS is turned
off. It's useful for having a controlled higher level of verbosity.

usage:
------

    **str_debug** arg [...]

options:
--------

    - *STR_DEBUG_SUPPRESS*, default is "1"
    - *STR_DEBUG_FORMAT*, defalt is "%s\n"

example:
--------

    .. code-block:: bash

        #!/bin/bash

        start() {
            source <(curl -sSLf http://bash.libs.cf/latest/sys)
            source <(curl -sSLf http://bash.libs.cf/latest/str)

            STR_DEBUG_SUPPRESS="0" STR_DEBUG_FORMAT="DEBUG: %s\n" \
              str_debug "The queue is empty"
        }

        start

|

str_err
=======

Prints to the STDERR with an ability to set a format.

usage:
------

    **str_err** arg [...]

options:
--------

    - *STR_ERR_SUPPRESS*, default is "0"
    - *STR_ERR_FORMAT*, default is "%s\n"

example:
--------

    .. code-block:: bash

        #!/bin/bash

        __str_init__() {
            STR_ERR_FORMAT="[ERROR]: %s\n"
        }

        start() {
            source <(curl -sSLf http://bash.libs.cf/latest/sys)
            source <(curl -sSLf http://bash.libs.cf/latest/str)

            str_err "the connection has been closed!"
            STR_ERR_FORMAT="WARN: %s\n" \
                str_err "too much arguments."
        }

        start

|

str_readline
============

Reads symbols from the STDIN or a file descriptor, until it faced a delimiter
or the EOF. A delimiter can be defined. It also doesn't matter if
a string ends with a specified delimiter (by default it's '\n') or not.
That's why it's much safer to be used in a while loop to read a stream
which may not have a defined delimiter at the end of the last string.

usage:
------

    **str_readline** [--delim char] [--fd num] [--] var

parameters:
-----------

    - *--delim*, a delimiter of a string (default is '\n')
    - *--fd*, a file descriptor to read from (default is 0)
    - *var*, a variable for storing a result

examples:
---------

    .. code-block:: bash

        #!/bin/bash

        start() {
            source <(curl -sSLf http://bash.libs.cf/latest/sys)
            source <(curl -sSLf http://bash.libs.cf/latest/str)

            # the result should contain all 3 strings and first 2 start with spaces
            printf '  Hi!\n    How are you?\nBye' | \
                while str_readline str; do echo "${str}"; done

            # reads strings which end with '\0' symbol instead of '\n'
            cat /proc/self/environ | \
                while str_readline --delim '' str; do echo "[${str}]"; done
        }

        start

|

str_readlines
=============

Reads strings from the STDIN until it faced the EOF and save them in an array.
It also behaves correctly if there is no a delimiter at the end of 
the last string.

usage:
------

    **str_readlines** [--delim char] [--fd num] [--] arr

parameters:
-----------

    - *--delim*, a delimiter of a string (default is $'\n')
    - *--fd*, a file descriptor to read from (default is 0)
    - *arr*, an array variable for storing the result

example:
--------

    .. code-block:: bash

        #!/bin/bash

        start() {
            source <(curl -sSLf http://bash.libs.cf/latest/sys)
            source <(curl -sSLf http://bash.libs.cf/latest/str)

            # reads strings which end with '\0' symbol instead of '\n'
            str_readlines --delim $'\0' myenv < /proc/self/environ && \
                echo "${myenv[0]}"
        }

        start

|

str_format
==========

This is a wrapper around printf which allows you to have a formated output
for data taken from the stdin. In this case the whole stream is considered
as one blob until it faces '\0' or the EOF. It is also possible to define
as an input the last parameter (input) as a source of data instead
of using the stdin. An output can be sent to another variable or
to the stdout if '-' was used instead of a variable's name.

usage:
------

    **str_format** format_string [output_var|-] [input]

parameters:
-----------

    - *format_string*, a common printf's format string
    - *output_var* or *-*, a variable for saving the output. If it's empty or '-', then prints to the stdout
    - *input*, if it's set, then it's used as a source of data. In this case, the second parameter cannot be empty!

examples:
---------

    .. code-block:: bash

        #!/bin/bash

        start() {
            source <(curl -sSLf http://bash.libs.cf/latest/sys)
            source <(curl -sSLf http://bash.libs.cf/latest/str)

            str_format "%014.2f" my_float "1.48732599" && echo ${my_float}
            str_format "The current time: %(%H:%M:%S)T\n" - "$(date '+%s')"
            echo -ne 'Hello\nWorld' | str_format "[%s]\n"
        }

        start

|

str_rstrip
==========

Removes all occurrences of a specified pattern from the right side.
It's important to notice that the function reads the whole stream
as one blob until it faces '\0' or the end of data. All other special symbols
are treated as normal, including '\n'. The result can be saved to a variable
or sent to the stdout without adding '\n' to the end, as is.

usage:
------

    **str_rstrip** [pattern] [var]

parameters:
-----------

    - *pattern*, a pattern is the same as in pathname expansion. Default is a new line '\n'
    - *var*, a variable where the result will be saved, optional

example:
--------

    .. code-block:: bash

        #!/bin/bash

        start() {
            source <(curl -sSLf http://bash.libs.cf/latest/sys)
            source <(curl -sSLf http://bash.libs.cf/latest/str)

            str_rstrip < <(printf "Hello\n\n\n\n")
        }

        start

|

str_lstrip
==========

Removes all occurrences of a specified pattern from the left side.
It's important to notice that the function reads the whole stream
as one blob until it faces '\0' or the end of data. All other special symbols
are treated as normal, including '\n'. The result can be saved to a variable
or sent to stdout without adding '\n' to the end, as is.

usage:
------

    **str_lstrip** [pattern] [var]

parameters:
-----------

    - *pattern*, a pattern is the same as in pathname expansion. Default is a space ' '
    - *var*, a variable where the result will be saved, optional

example:
--------

    .. code-block:: bash

        #!/bin/bash

        start() {
            source <(curl -sSLf http://bash.libs.cf/latest/sys)
            source <(curl -sSLf http://bash.libs.cf/latest/str)

            str_lstrip <<< "     Hello"
        }

        start

|

str_strip
=========

Removes all occurrences of a specified pattern from both sides.
Keep in mind that usualy strings end with a new line symbol '\n' and
to use this function, first you need to remove it from the right.

usage:
------

    **str_strip** [pattern] [var]

parameters:
-----------

    - *pattern*, a pattern is the same as in pathname expansion. Default is a space ' '
    - *var*, a variable where the result will be saved, optional

example:
--------

    .. code-block:: bash

        #!/bin/bash

        start() {
            source <(curl -sSLf http://bash.libs.cf/latest/sys)
            source <(curl -sSLf http://bash.libs.cf/latest/str)

            { str_rstrip | str_strip | str_format "[%s]\n"; } <<< "   Hello   "
        }

        start

|

