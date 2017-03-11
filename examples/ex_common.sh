#!/bin/bash

# Сделать ф-и экспортируемыми
# bootstraping для import()
# Добавить подключение модулей в текущем каталоге исполняемого файла
# Добавить  __help__, __list__


run()
{
    source <(exec 3<>/dev/tcp/lib-sh.vorakl.name/80; echo -e "GET http://lib-sh.vorakl.name/common HTTP/1.1\nHost: lib-sh.vorakl.name\nUser-Agent: lib-sh-import\nConnection: close\n\n" >&3; <&3 tr -d '\r'  | sed '1,/^$/d'; exec 3>&-)

    import "http://lib-sh.vorakl.name/common" "once"
    import "http://lib-sh.vorakl.name/common" "always" "/usr/local/lib-sh.vorakl.name/"

    say "This is say"
    err "This is err"
    die "This is die"

}


__common_init__() { 
    SAY_PRE="$(date '+%Y-%m-%d %H:%M:%S'): "
    ERR_PRE="err: "
#    SAY_VERBOSE=false
#    ERR_VERBOSE=false
    DIE_EXITCODE=2
}

import() {
    local _locdir _locpath

    _locdir=$(basename $(dirname "$1"))
    _locpath=${_locdir}/$(basename "$1")

    if [ ! -d ${_locdir} ]; then
        mkdir -p ${_locdir} &> /dev/null || { echo "Cannot create the directory ${_locdir}" >&2; exit 1; }
    fi
    case "$2" in
        once) [ -f "${_locpath}" ] && true || curl -sfL "$1" > ${_locpath} ;;
           *) curl -sfL "$1" > ${_locpath} ;;
    esac && \
    source ${_locpath}
}

run "$@"
