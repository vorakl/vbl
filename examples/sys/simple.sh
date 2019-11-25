#!/bin/bash

start() {
    source <(curl -sSLf http://bash.libs.cf/latest/sys)

    sys_cmd echo "Hello World"
    sys_cmd -v cp
    sys_cmd -p df -h
}

start
