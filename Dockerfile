FROM debian:bullseye AS firstStep

#copy lib and bin
COPY --from=icerleer/aisbase:latest /usr/lib/lib* /usr/lib/ 
COPY --from=icerleer/aisbase:latest /usr/lib/x86_64-linux-gnu /usr/lib/x86_64-linux-gnu
COPY --from=icerleer/aisbase:latest /lib/x86_64-linux-gnu /lib/x86_64-linux-gnu
COPY --from=icerleer/aisbase:latest /usr/local/apr /usr/local/apr
COPY --from=icerleer/aisbase:latest /usr/local/unimrcp /usr/local/unimrcp
COPY --from=icerleer/aisbase:latest /usr/local/freeswitch /usr/local/freeswitch

# set file link
RUN ln -sf /usr/local/freeswitch/bin/freeswitch /usr/bin/ \
    && ln -sf /usr/local/freeswitch/bin/fs_cli /usr/bin/

# set timezone
ENV TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# set time locale (and get wget tool)
RUN apt-get update && apt-get install -y locales wget \
    && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8 \
    && rm -rf /var/lib/apt/lists/*
ENV LANG=en_US.utf8

## 部署时使用host网络配置，不需要预设映射端口
## ESL port 21014
#EXPOSE 21010/tcp 21010/udp 21012/tcp 21012/udp

# Volumes
## Freeswitch Configuration 
VOLUME ["/usr/local/freeswitch/conf"]

# Limits Configuration
COPY build/aiswitch.limits.conf /etc/security/limits.d/

# Healthcheck to make sure the service is running
# SHELL       ["/bin/bash"]
# HEALTHCHECK --interval=15s --timeout=5s \
#     CMD  fs_cli -P21014 -p "long@123" -x status | grep -q ^UP || exit 1

# copy entrypoint
COPY docker-entrypoint.sh /
# set entrypoint
ENTRYPOINT ["/docker-entrypoint.sh"]
# set args
CMD ["aiswitch"]