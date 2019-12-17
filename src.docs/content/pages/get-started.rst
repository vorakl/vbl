Get started
###########

:slug: get-started
:summary: All useful functions in one example

|

First of all, let's take a look at the "Hello World" example in terms of this
library:

.. code-block:: bash

    #!/bin/bash

    start() {
        source <(curl -sSLf http://bash.libs.cf/stable/sys)
        source <(curl -sSLf http://bash.libs.cf/stable/str)

        str_say "Hello World"
    }

    start

|

In this example, I'm gonna import a few modules and show some common use cases,
all in one script:

.. code-block:: bash

    #!/bin/bash

    __str_init__() {
        STR_SAY_FORMAT="INFO: %s\n"
        STR_ERR_FORMAT="ERROR: %s\n"
    }

    __exec_init__() {
        EXEC_RUN_WARN_FORMAT="WARN: '%s' has exited with status code %d\n"
        EXEC_DIE_FORMAT="FATAL: '%s' has failed with an exit code '%d'\n"
        EXEC_CHECK_CMD_ENSURE_FORMAT="FATAL: there is no '%s' command\n"
        EXEC_CHECK_CMD_ENSURE_EXITCODE="28"
        EXEC_RERUN_TRIES="3"
    }

    start() {
        source <(curl -sSLf http://bash.libs.cf/stable/sys)
        source <(curl -sSLf http://bash.libs.cf/stable/str)
        source <(curl -sSLf http://bash.libs.cf/stable/exec)

        # Ensures that these tools exist
        exec_check_cmd --ensure cat cp

        # Runs a failing command with no output and only warns about an error
        exec_run --silent --warn cat /nonexistent

        # Runs a command silently but if it fails, then exits with an error
        exec_run --silent cp /etc/resolv.conf /tmp/ || \
            exec_die --exitcode 34 "cp" "$?"
        
        # Runs a wrong command 3 times and 1 sec sleep, and ignores a non-zero
        # exit code after the last try
        exec_run --ignore \
            exec_rerun --sleep 1 bash -c 'echo "fail"; exit 1'

        false || str_err "A false state occured!"

        # Reads strings which end with '\0' symbol instead of '\n'
        str_readlines --delim $'\0' myenv < /proc/self/environ && \
            echo "${myenv[0]}"

        # Saves a formated fp-number in a variable
        str_format "%014.2f" my_float "1.48732599" && echo ${my_float}

        # Takes a current time in Unix-time format and prints it for human
        str_format "The current time: %(%H:%M:%S)T\n" - "$(date '+%s')"

        # Removes all '\n' from the right side
        str_rstrip < <(printf "Hello\n\n\n\n"); echo

        # Removes all leading spaces
        str_lstrip <<< "     Hello"

        # First, remove '\n' on the right, then ' ' from both sides
        { str_rstrip | str_strip; } <<< "   Hello   "; echo
    }

    start
