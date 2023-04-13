#!/bin/bash
set -e

# Source docker-entrypoint.sh:
if [ "$1" = 'freeswitch' ]; then
    # 如果是外部映射的配置文件目录，那么拷贝初始化数据到映射的目录
    if [ ! -f "/usr/local/aiswitch/conf/freeswitch.xml" ]; then
        #软连接目录
        ln -sf /usr/local/freeswitch /usr/local/aiswitch
    fi
    
    if [ -d /docker-entrypoint.d ]; then
        for f in /docker-entrypoint.d/*.sh; do
            [ -f "$f" ] && . "$f"
        done
    fi
    
    exec freeswitch -c -nonat
fi

exec "$@"
