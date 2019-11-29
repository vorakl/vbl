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
* str_lstrip_ <func>
* str_rstrip_ <func>
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
is loaded by defining them as a list in the 'source' command or in the
`__str_exported`_ variable.

    .. code-block:: bash

        #!/bin/bash

        start() {
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
            source <(curl -sSLf http://bash.libs.cf/latest/str)
        }

        start

|

str_say
=======

|

str_debug
=========

|

str_err
=======

|

str_readline
============

|

str_readlines
=============

|

str_format
==========

|

str_lstrip
==========

|

str_rstrip
==========

|

str_strip
=========

|

