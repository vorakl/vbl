sys
###

:slug: sys
:summary: Essential system functions


API
===

* `__sys_version`_ <var>
* `__sys_exported`_ <var>
* `__sys_init__`_ <func>
* `sys_cmd`_  <func>


USAGE
=====

source module_name [list of functions to export]


__sys_version
=============

This readonly variable contains a current module's version.

__sys_exported
==============

This variable contains a list (separated by a space symbol) of functions that
will be exported. It can be altered in the `__sys_init__` function.

__sys_init__
============

This function has to be defined before the module is imported.
It can be used for setting up default values for any function's variables.

Example:
--------

.. code-block:: bash                                                            
                                                                                
    #!/bin/bash

    __sys_init__() {
        __sys_exported="sys_cmd"
    }

    start() {
        source <(curl -sSLf http://bash.libs.cf/latest/sys)
    }

    start


sys_cmd
=======

A wrapper for the builtin **'command'** for minimizing a risk of reloading
It works together with **'unset builtin'** in the `__sys_conf__` and
the whole idea will work out only if Bash is run with the **'--posix'** option
which doesn't allow to reload **'unset'** builtin function.
Anyway, you decide how deep is your paranoia ;)
It's intended to be used for running builtin commands or standard tools.
First, it checks in builtins. Then, it tries to find an external command.

Possible options are:

* -p  search in standard paths only
* -v  check if a command exists

Example:
--------

.. code-block:: bash                                                            

    #!/bin/bash

    start() {
        source <(curl -sSLf http://bash.libs.cf/latest/sys)

        sys_cmd echo "Hello World"
        sys_cmd -v cp
        sys_cmd -p df -h
    }

    start
