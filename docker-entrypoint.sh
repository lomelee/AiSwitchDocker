#!/bin/bash
set -e

# Source docker-entrypoint.sh:
if [ "$1" = 'freeswitch' ]; then

    if [ ! -f "/usr/local/freeswitch/conf/freeswitch.xml" ]; then
        mkdir -p /usr/local/freeswitch/conf
        cp -varf /usr/share/freeswitch/conf/vanilla/* /usr/local/freeswitch/conf/
    fi

    chown -R freeswitch:freeswitch /usr/local/freeswitch/bin
    chown -R freeswitch:freeswitch /usr/local/freeswitch/{run,lib}
    
    if [ -d /docker-entrypoint.d ]; then
        for f in /docker-entrypoint.d/*.sh; do
            [ -f "$f" ] && . "$f"
        done
    fi
    
    exec gosu freeswitch /usr/local/freeswitch/bin/freeswitch -u freeswitch -g freeswitch -nonat -c
fi

exec "$@"
