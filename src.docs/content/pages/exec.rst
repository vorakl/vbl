Module: exec
############

:slug: exec
:summary: Functions related to executing commands


API
===

* `__exec_version`_ <var>
* `__exec_exported`_ <var>
* EXEC_RUN_WARN_FORMAT <var>
* EXEC_RUN_ENSURE_FORMAT <var>
* EXEC_DIE_EXITCODE <var>
* EXEC_DIE_FORMAT <var>
* EXEC_CHECK_CMD_WARN_FORMAT <var>
* EXEC_CHECK_CMD_ENSURE_FORMAT <var>
* EXEC_RERUN_TRIES <var>
* EXEC_RERUN_SLEEP <var>
* `__exec_init__`_ <func>
* exec_run_ <func>
* exec_die_ <func>
* exec_check_cmd_ <func>
* exec_rerun_ <func>

|

REQIRES
=======

* sys
* str

|

USAGE
=====
    ::

        source module_name [list of functions to export]

By default, all functions are exported, so they can be used in sub-shells.
It is also possible to specify which functions should be exported when a module
is loaded by defining them as a list in the 'source' command or in the
`__exec_exported`_ variable.

example:
--------

    .. code-block:: bash

        #!/bin/bash

        start() {
            source <(curl -sSLf http://bash.libs.cf/latest/sys)
            source <(curl -sSLf http://bash.libs.cf/latest/str)
            source <(curl -sSLf http://bash.libs.cf/latest/exec) exec_run
        }

        start

|

__exec_version
==============

This readonly variable contains a current module's version.

|

__exec_exported
===============

This variable contains a list (separated by a space symbol) of functions that
will be exported. It can be altered in the `__exec_init__`_ function.

|

__exec_init__
=============

This function has to be defined before the module is imported.
It can be used for setting up default values for any function's variables.

example:
--------

    .. code-block:: bash

        #!/bin/bash

        __exec_init__() {
            __exec_exported="exec_run exec_rerun"
        }

        start() {
            source <(curl -sSLf http://bash.libs.cf/latest/sys)
            source <(curl -sSLf http://bash.libs.cf/latest/str)
            source <(curl -sSLf http://bash.libs.cf/latest/exec)
        }

        start

|

exec_run
========

A wrapper to run commands and control output, exit status, etc.

usage:
------
    ::

        exec_run [ --silent | \ 
                  (--no-out|--save-out var) | \
                  (--no-err|--save-err var|--err-to-out) \
                 ] \
                 [--ignore|--warn|--ensure] \
                 [--] \
                 cmd [arg [...]]

parameters:
-----------

    - *--silent*,
      suppress stdout and stderr
    - *--no-out*,
      suppress stdout
    - *--no-err*,
      suppress stderr
    - *--save-out var*,
      save stdout into array variable 'var' (up to 64 KB)
    - *--save-err var*,
      save stderr into array variable 'var' (up to 64 KB)
    - *--err-to-out*,
      join stderr and stdout in one stream of stdout 
    - *--ignore*,
      ignore non zero exit status
    - *--warn*,
      ignore non zero exit status and print an error which is built
      of the ordered FORMAT's elements: %s - errmsg, %d - exitcode
    - *--ensure*,
      exit on any non-zero exitstatus and print an error which
      is built of the ordered FORMAT's elements:
      %s - errmsg, %d - exitcode, %d - die exitcode
 
options:
--------

    - *EXEC_RUN_WARN_FORMAT*,
      default is ``"Command '%s' has failed with exit status %d. Ignoring...\n"``
    - *EXEC_RUN_ENSURE_FORMAT*,
      default is ``"Command '%s' has failed with exit status %d. Exiting
      (exitcode=%d)...\n"``

examples:
---------

    .. code-block:: bash

        #!/bin/bash

        start() {
            source <(curl -sSLf http://bash.libs.cf/latest/sys)
            source <(curl -sSLf http://bash.libs.cf/latest/str)
            source <(curl -sSLf http://bash.libs.cf/latest/exec)
            
            set -o errexit
            # the script doesn't terminate after this command
            exec_run --silent --ignore cat /nonexistent
        }

        start

    .. code-block:: bash

        #!/bin/bash

        __exec_init__() {
            EXEC_RUN_WARN_FORMAT="[WARN] '%s' has exited with status code %d\n"
        }

        start() {
            source <(curl -sSLf http://bash.libs.cf/latest/sys)
            source <(curl -sSLf http://bash.libs.cf/latest/str)
            source <(curl -sSLf http://bash.libs.cf/latest/exec)

            set -o errexit 
            # the script doesn't terminate after this command
            exec_run --silent --warn cat /nonexistent
        }

        start

|

exec_die
========

Prints an error message using **'str_err'** function to the STDERR and
exits with an appropriate exit code.

usage:
------
    ::

        exec_die [--exitcode 0..255] [--] arg [...]

parameters:
-----------

    - *--exitcode*,
      set an exit code. It has a precedence on the EXEC_DIE_EXITCODE option

options:
--------

    - *EXEC_DIE_EXITCODE*,
      default is "1"
    - *EXEC_DIE_FORMAT*,
      default is ``"%s\n"``
  
examples:
---------

    .. code-block:: bash

        #!/bin/bash

        start() {
            source <(curl -sSLf http://bash.libs.cf/latest/sys)
            source <(curl -sSLf http://bash.libs.cf/latest/str)
            source <(curl -sSLf http://bash.libs.cf/latest/exec)
            
            exec_die --exitcode 15 "A host is not reachable"
        }

        start

    .. code-block:: bash

        #!/bin/bash

        __exec_init__() {
            EXEC_DIE_FORMAT="FATAL: '%s' has failed with an exit code '%d'\n"
        }

        start() {
            source <(curl -sSLf http://bash.libs.cf/latest/sys)
            source <(curl -sSLf http://bash.libs.cf/latest/str)
            source <(curl -sSLf http://bash.libs.cf/latest/exec)

            exec_run --silent cp /from /to || exec_die --exitcode 34 "cp" "$?"
        }

        start

|

exec_check_cmd
==============

Checks if commands exist. Return an error on the first absent command.

usage:
------
    ::

        exec_check_cmd [--warn|--ensure] [--] cmd [...]

parameters:
-----------

    - *--warn*,
      prints a error message about the first missing command, but doesn't return
      any errors, keeps checking. The message's FORMAT is made of the followinf
      elements:  %s - command
    - *--ensure*,
      exits with an error message on the first missing command. The message's
      FORMAT is made of the followinf elements: %s - command

options:
--------

    - *EXEC_CHECK_CMD_WARN_FORMAT*,
      default is ``"Command '%s' does not exist.\n"``
    - *EXEC_CHECK_CMD_ENSURE_FORMAT*,
      default is ``"Command '%s' does not exist. Exiting...\n"``
    - *EXEC_CHECK_CMD_ENSURE_EXITCODE*,
      default is "1"

examples:
---------

    .. code-block:: bash

        #!/bin/bash

        start() {
            source <(curl -sSLf http://bash.libs.cf/latest/sys)
            source <(curl -sSLf http://bash.libs.cf/latest/str)
            source <(curl -sSLf http://bash.libs.cf/latest/exec)

            exec_check_cmd cp rm
        }

        start

    .. code-block:: bash

        #!/bin/bash

        start() {
            source <(curl -sSLf http://bash.libs.cf/latest/sys)
            source <(curl -sSLf http://bash.libs.cf/latest/str)
            source <(curl -sSLf http://bash.libs.cf/latest/exec)

            exec_check_cmd --warn touch cp nonexistent od
        }

        start

    .. code-block:: bash

        #!/bin/bash

        __exec_init__() {
            EXEC_CHECK_CMD_ENSURE_FORMAT="FATAL: there is no '%s' command\n"
            EXEC_CHECK_CMD_ENSURE_EXITCODE="28"
        }

        start() {
            source <(curl -sSLf http://bash.libs.cf/latest/sys)
            source <(curl -sSLf http://bash.libs.cf/latest/str)
            source <(curl -sSLf http://bash.libs.cf/latest/exec)

            exec_check_cmd --ensure head tail nonexistent mv
        }

        start

|

exec_rerun 
==========

Rerun a command if it fails.

usage:
------
    ::

        exec_rerun [--tries num] [--sleep sec] [--] cmd [args]

parameters:
-----------

    - *--tries*,
      a number of tries to run a command
    - *--sleep*,
      a pause in seconds between tries 

options:
--------

    - *EXEC_RERUN_TRIES*,
      default is "5"
    - *EXEC_RERUN_SLEEP*,
      default is "0"

examples:
---------

    .. code-block:: bash

        #!/bin/bash

        start() {
            source <(curl -sSLf http://bash.libs.cf/latest/sys)
            source <(curl -sSLf http://bash.libs.cf/latest/str)
            source <(curl -sSLf http://bash.libs.cf/latest/exec)

            exec_rerun bash -c 'echo fail; exit 1'
        }

        start

    .. code-block:: bash

        #!/bin/bash

        __exec_init__() {
            EXEC_RERUN_TRIES="3"
        }

        start() {
            source <(curl -sSLf http://bash.libs.cf/latest/sys)
            source <(curl -sSLf http://bash.libs.cf/latest/str)
            source <(curl -sSLf http://bash.libs.cf/latest/exec)

            exec_rerun --sleep 1 exec_run --no-err ping hostname
        }

        start

|

