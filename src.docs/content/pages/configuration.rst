Configuration
#############

:slug: configuration
:summary: Changing default values of functions' options
:sidebar: False

General information
===================

Many functions in modules can be reconfigured at run-time by changing values of
their options. All mutable options can be found in the documentation.
This allows us to use the same code everywhere and change a function's behavior
(e.g. messages format, exit codes) for particular needs. It's possible to do
either at global scope by setting them once in the beginning of a script or
in-line to modify a certain call.

|

How it works
============

It works as follows. Every module has an entrypoint, a function which is called
like ``__${module}_main__``. It's executed automaticaly when a module is included.
In the next step, ``__${module}_conf__`` is executed which runs all available
``__${func}_conf__`` functions for setting default values.
Then, ``__${module}_main__`` checks if the ``__${module}_init__`` function has
been previosly defined (in a script which includes a module). If so, it's also
executed. This is exactly the function where all needed options should be redefined.

|

Example
=======

.. code-block:: bash

    #!/bin/bash

    start() {
        source <(curl -sSLf http://vbl.vorakl.com/stable/sys)
        source <(curl -sSLf http://vbl.vorakl.com/stable/str)
        
        str_say "Booting..."
        str_err "Something went wrong!"
    }

    __str_init__() {
        STR_SAY_FORMAT="INFO: %s\n"
        STR_ERR_FORMAT="ERROR: %s\n"
    }

    start
