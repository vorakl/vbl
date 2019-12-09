Module: matrix
##############

:slug: matrix
:summary: Matrix (2D-arrays) Abstract Data Type

API
===

* `__matrix_version`_ <var>
* `__matrix_exported`_ <var>
* MATRIX_GET_FORMAT <var>
* `__matrix_init__`_ <func>
* matrix_init_ <func>
* matrix_get_ <func>
* matrix_set_ <func>
* matrix_destroy_ <func>

|

REQIRES
=======

* sys
* str

USAGE
=====
    ::

        source matrix [list of functions to export]

By default, all functions are exported, so they can be used in sub-shells.
It is also possible to specify which functions should be exported when a module
is loaded by defining them as a list in the 'source' command or in the
`__matrix_exported`_ variable.

example:
--------

    .. code-block:: bash

        #!/bin/bash

        start() {
            source <(curl -sSLf http://bash.libs.cf/stable/sys)
            source <(curl -sSLf http://bash.libs.cf/stable/str)
            source <(curl -sSLf http://bash.libs.cf/stable/matrix)
        }

        start

|

__matrix_version
================

This readonly variable contains a current module's version.

|

__matrix_exported
=================

This variable contains a list (separated by a space symbol) of functions that
will be exported. It can be altered in the `__matrix_init__`_ function.

|

__matrix_init__
===============

This function has to be defined before the module is imported.
It can be used for setting up default values for any function's variables.

example:
--------

    .. code-block:: bash

        #!/bin/bash

        __matrix_init__() {
            MATRIX_GET_FORMAT="'%s'\n"
        }

        start() {
            source <(curl -sSLf http://bash.libs.cf/stable/sys)
            source <(curl -sSLf http://bash.libs.cf/stable/str)
            source <(curl -sSLf http://bash.libs.cf/stable/matrix)
        }

        start

|

matrix_init
===========

Creates a new instance and initialize it.

usage:
------
    ::

        matrix_init name X Y value ...

parameters:
-----------

    - *name*, the name of an instance
    - *X*, a number of columns
    - *Y*, a number of rows
    - *values*, all values presented row by row, accordingly to X and Y

example:
--------

    .. code-block:: bash

        #!/bin/bash

        start() {
            source <(curl -sSLf http://bash.libs.cf/stable/sys)
            source <(curl -sSLf http://bash.libs.cf/stable/str)
            source <(curl -sSLf http://bash.libs.cf/stable/matrix)

            matrix_init my_matrix \
                        3 2 \
                        one two three \
                        "1 1" "2 2" "3 3" 
            matrix_destroy my_matrix
        }

        start

|

matrix_get
==========

Gets an element.

usage:
------
    ::

        matrix_get name X Y

parameters:
-----------

    - *name*, the name of an instance
    - *X*, a column number, starts from 0
    - *Y*, a row number, start from 0

option:
-------

    - *MATRIX_GET_FORMAT*, default is "%s\n"

example:
--------

    .. code-block:: bash

        #!/bin/bash

        __matrix_init__() {
            MATRIX_GET_FORMAT="'%s'\n"
        }

        start() {
            source <(curl -sSLf http://bash.libs.cf/stable/sys)
            source <(curl -sSLf http://bash.libs.cf/stable/str)
            source <(curl -sSLf http://bash.libs.cf/stable/matrix)

            matrix_init my_matrix 1 1 "the element"
            matrix_get my_matrix 0 0
            matrix_destroy my_matrix
        }

        start

|

matrix_set
==========

Sets an element.

usage:
------
    ::

        matrix_get name X Y value

parameters:
-----------

    - *name*, the name of an instance
    - *X*, a column number, starts from 0
    - *Y*, a row number, start from 0
    - *value*, a new value for the element

example:
--------

    .. code-block:: bash

        #!/bin/bash

        start() {
            source <(curl -sSLf http://bash.libs.cf/stable/sys)
            source <(curl -sSLf http://bash.libs.cf/stable/str)
            source <(curl -sSLf http://bash.libs.cf/stable/matrix)

            matrix_init my_matrix 1 1 "the element"
            matrix_set my_matrix 0 0 "Hello World"
            matrix_destroy my_matrix
        }

        start

|

matrix_destroy
==============

Removes an instance.

usage:
------
    ::

        matrix_destroy name

parameter:
-----------

    - *name*, the name of an instance

example:
--------

    .. code-block:: bash

        #!/bin/bash

        start() {
            source <(curl -sSLf http://bash.libs.cf/stable/sys)
            source <(curl -sSLf http://bash.libs.cf/stable/str)
            source <(curl -sSLf http://bash.libs.cf/stable/matrix)

            matrix_init my_matrix 1 1 "the element"
            matrix_destroy my_matrix
        }

        start

|
