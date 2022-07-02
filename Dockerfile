FROM debian:bullseye

#copy lib and bin
COPY --from=icerleer/aisbase:latest /usr/lib/lib* /usr/lib/
COPY --from=icerleer/aisbase:latest /usr/local/freeswitch /usr/local/freeswitch
COPY --from=icerleer/aisbase:latest /usr/lib/x86_64-linux-gnu /usr/lib/x86_64-linux-gnu

# set file link
RUN ln -sf /usr/local/freeswitch/bin/freeswitch /usr/bin/ \
    && ln -sf /usr/local/freeswitch/bin/fs_cli /usr/bin/

# set timezone
ENV TZ=Asia/Shanghai
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

# set time locale
RUN apt-get update && apt-get install -y locales \
    && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8 \
    && rm -rf /var/lib/apt/lists/*
ENV LANG en_US.utf8

# copy config
RUN mv /usr/local/freeswitch/.conf /usr/local/freeswitch/conf 

## Ports
# Open the container up to the world.
### 8021 fs_cli, 5060 5061 5080 5081 sip and sips, 64535-65535 rtp
# EXPOSE 8021/tcp \ 
#     5060/tcp 5060/udp 5080/tcp 5080/udp \
#     5061/tcp 5061/udp 5081/tcp 5081/udp \
#     7443/tcp \
#     5070/udp 5070/tcp \
#     64535-65535/udp \
#     16384-32768/udp

# Volumes
## Freeswitch Configuration ## Tmp so we can get core dumps out
# VOLUME ["/usr/local/freeswitch/conf"]
# VOLUME ["/tmp"]

# # Limits Configuration
# COPY  build/AiSwitch.limits.conf /etc/security/limits.d/freeswitch.limits.conf

# # Healthcheck to make sure the service is running
# SHELL       ["/bin/bash"]
# HEALTHCHECK --interval=15s --timeout=5s \
#     CMD  fs_cli -x status | grep -q ^UP || exit 1

# # copy entrypoint
# COPY docker-entrypoint.sh /
# # set entrypoint
# ENTRYPOINT ["/docker-entrypoint.sh"]
# # set args
# CMD ["freeswitch"]