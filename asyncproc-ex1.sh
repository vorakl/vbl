#!/bin/bash

source asyncproc

export ASYNCPROC_VERBOSE=true

trap asyncproc_stop EXIT TERM

asyncproc_run()
{
    echo 1234 110 > ${ASYNCPROC_HANDLER_EC_INPUT}
    echo 1235 0 > ${ASYNCPROC_HANDLER_EC_INPUT}
    echo 1236 112 > ${ASYNCPROC_HANDLER_EC_INPUT}
    echo 1234 Pinging... > ${ASYNCPROC_HANDLER_STDOUT_INPUT}
    echo 1235 Listens on the port 200 > ${ASYNCPROC_HANDLER_STDOUT_INPUT}
    echo 1236 Copying files... > ${ASYNCPROC_HANDLER_STDOUT_INPUT}
    echo 1234 The host is unreachble > ${ASYNCPROC_HANDLER_STDERR_INPUT}

    asyncproc_get_exitcodes "dump"
    asyncproc_get_stdouts "dump"
    asyncproc_get_stderrs "dump"
    asyncproc_say "Workers: ${asyncproc_workers[*]}"
    asyncproc_say "Exit codes: ${asyncproc_exitcodes[*]}"
    asyncproc_say "Files with Stdout: ${asyncproc_stdouts[*]}"
    asyncproc_say "Files with Stderr: ${asyncproc_stderrs[*]}"

    echo 1237 114 > ${ASYNCPROC_HANDLER_EC_INPUT}
    echo 1238 130 > ${ASYNCPROC_HANDLER_EC_INPUT}
    echo 1239 0 > ${ASYNCPROC_HANDLER_EC_INPUT}
    echo 1237 Done > ${ASYNCPROC_HANDLER_STDOUT_INPUT}
    echo 1238 Just loading... > ${ASYNCPROC_HANDLER_STDOUT_INPUT}
    echo 1239 Info about something > ${ASYNCPROC_HANDLER_STDOUT_INPUT}
    echo 1238 The file does not exist > ${ASYNCPROC_HANDLER_STDERR_INPUT}
}

#asyncproc_handler_ec_add_local() {
#    [[ $3 -ne 0 ]] && { echo "!!! BING !!! (${asyncproc_main_pid})"; kill -TERM $$; }
#}

asyncproc_start
asyncproc_run
asyncproc_stop
echo
echo "--------"
echo
asyncproc_start
asyncproc_run
echo
echo "--------"
echo
