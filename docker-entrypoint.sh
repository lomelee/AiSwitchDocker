#!/bin/bash
set -e

# Source docker-entrypoint.sh:
if [ "$1" = 'freeswitch' ]; then
    # 如果是外部映射的配置文件目录，那么拷贝初始化数据到映射的目录
    if [ ! -f "/usr/local/freeswitch/conf/freeswitch.xml" ]; then
        mkdir -p /usr/local/freeswitch/conf
        cp -arf /usr/local/freeswitch/.aisConf/* /usr/local/freeswitch/conf/
    fi

    # 创建默认的声音文件
    if [ ! -f "/usr/local/freeswitch/sounds" ]; then
        mkdir -p /usr/local/freeswitch/sounds
        cp -arf /usr/local/freeswitch/.sounds/* /usr/local/freeswitch/sounds/
    fi

    # 创建默认的脚本文件
    if [ ! -f "/usr/local/freeswitch/scripts" ]; then
        mkdir -p /usr/local/freeswitch/scripts
        cp -arf /usr/local/freeswitch/.scripts/* /usr/local/freeswitch/scripts/
    fi

    # 创建默认的ASR语法文件夹
    if [ ! -f "/usr/local/freeswitch/grammar" ]; then
        mkdir -p /usr/local/freeswitch/grammar
        cp -arf /usr/local/freeswitch/.grammar/* /usr/local/freeswitch/grammar/
    fi

    # 创建默认的录音文件夹
    if [ ! -f "/usr/local/freeswitch/recordings" ]; then
        mkdir -p /usr/local/freeswitch/recordings
    fi

    # 创建默认的日志文件
    if [ ! -f "/usr/local/freeswitch/log" ]; then
        mkdir -p /usr/local/freeswitch/log
    fi
    
    # if [ -d /docker-entrypoint.d ]; then
    #     for f in /docker-entrypoint.d/*.sh; do
    #         [ -f "$f" ] && . "$f"
    #     done
    # fi
    
    # exec freeswitch -nc -nonat
fi
exec freeswitch -c -nonat
# 执行参数
#exec "$@"
