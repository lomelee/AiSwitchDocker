#!/bin/bash
set -e

# Source docker-entrypoint.sh:
if [ "$1" = 'freeswitch' ]; then
    # 如果是外部映射的配置文件目录，那么拷贝初始化数据到映射的目录
    if [ ! -f "/usr/local/freeswitch/conf/freeswitch.xml" ]; then
        mkdir -p /usr/local/freeswitch/conf
        cp -varf /usr/local/freeswitch/.conf/* /usr/local/freeswitch/conf/
    fi
    
    if [ -d /docker-entrypoint.d ]; then
        for f in /docker-entrypoint.d/*.sh; do
            [ -f "$f" ] && . "$f"
        done
    fi
    
    exec freeswitch -c
fi

exec "$@"
