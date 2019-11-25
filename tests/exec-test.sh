#!/usr/bin/env roundup

describe "Testing the 'exec' module..."

before() {
    cd ..
}

after() {
    cd -
}

it_checks_die_env() {
    if (EXEC_DIE_EXITCODE=13; exec_die "Have a nice day")
    then
        echo "This test does not work"
        return 1
    else
        (( $? == 13 ))
    fi
}

it_checks_die_param() {
    if (exec_die --exitcode 15 "Have a nice day")
    then
        echo "This test does not work"
        return 1
    else
        (( $? == 15 ))
    fi
}

it_checks_run_output_stdout() {
    r1="$(exec_run eval '{ str_say "Hello"; str_err "World"; }')"
    [[ "${r1}" == "Hello" ]]

    r2="$(exec_run --no-out eval '{ str_say "Hello"; str_err "World"; }')"
    [[ -z "${r2}" ]]
}

it_checks_run_output_stderr() {
    r1="$(exec_run str_err "hiddenError" 2>&1)"
    [[ ${r1} =~ "hiddenError" ]]
}

it_checks_run_output_join() {
    r1="$(exec_run --err-to-out \
          eval '{ STR_SAY_FORMAT="%s" str_say "Hello "; \
                  str_err "hiddenWorld"; }')"
    [[ ${r1} =~ "hiddenWorld" ]]
}

it_checks_run_output_silent() {
    r1="$(exec_run --silent str_say Hello)"
    [[ -z "${r1}" ]]
}

it_checks_run_output_save() {
    exec_run --save-out my_out --save-err my_err \
             eval '{ str_say "Hello"; str_err "World"; }'
    [[ "${my_out[0]/$'\n'/}" == "Hello" ]]
    [[ ${my_err[*]} =~ "World" ]]
}

it_checks_run_status_ignore() {
    exec_run --ignore false
}

it_checks_run_status_warn() {
    r1="$(EXEC_RUN_WARN_FORMAT="%s-%d\n" \
          exec_run --warn --no-err cat /nonexistent 2>&1)"
    [[ ${r1} =~ "cat-1" ]]
}

it_checks_run_status_ensure() {
    if r1="$(EXEC_DIE_EXITCODE=14; EXEC_RUN_ENSURE_FORMAT="%s-%d-%d\n" \
             exec_run --ensure --no-err cat /nonexistent 2>&1)"
    then
        echo "This test does not work"
        return 1
    else
        [[ ${r1} =~ "cat-1-14" ]]
    fi
}

it_checks_check_cmd() {
    exec_check_cmd rm mv cp
}

it_checks_check_cmd_status_warn() {
    if ! r1="$(EXEC_CHECK_CMD_WARN_FORMAT='%s' \
               exec_check_cmd --warn rm noncmd cp 2>&1)"
    then
        echo "This test does not work"
        return 1
    else
        [[ ${r1} =~ "noncmd" ]]
    fi
}

it_checks_check_cmd_status_insure() {
    if r1="$(EXEC_CHECK_CMD_ENSURE_FORMAT='%s' \
               EXEC_CHECK_CMD_ENSURE_EXITCODE=29 \
               exec_check_cmd --ensure rm noncmd cp 2>&1)"
    then
        echo "This test does not work"
        return 1
    else
        [[ ${r1} =~ "noncmd" && $? == "29" ]]
    fi
}

it_checks_rerun() {
    r1=$(exec_rerun bash -c 'echo 1; false' | wc -l)
    (( r1 == 5 ))
}

it_checks_rerun_tries() {
    r1=$(EXEC_RERUN_TRIES=3 exec_rerun bash -c 'echo 1; false' | wc -l)
    (( r1 == 3 ))

    r1=$(exec_rerun --tries 2 bash -c 'echo 1; false' | wc -l)
    (( r1 == 2 ))
}

it_checks_rerun_sleep() {
    s=$SECONDS
    exec_run --ignore exec_rerun --tries 2 --sleep 1 false
    f=$SECONDS
    (( (f - s) == 2 ))

    s=$SECONDS
    EXEC_RERUN_SLEEP=1 exec_run --ignore exec_rerun --tries 3 false
    f=$SECONDS
    (( (f - s) == 3 ))
}
