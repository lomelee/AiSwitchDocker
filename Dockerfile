FROM debian:bullseye

#copy lib and bin
COPY --from=icerleer/aisbase:latest /usr/lib/lib* /usr/lib/
COPY --from=icerleer/aisbase:latest /usr/lib/x86_64-linux-gnu /usr/lib/x86_64-linux-gnu
COPY --from=icerleer/aisbase:latest /lib/x86_64-linux-gnu /lib/x86_64-linux-gnu
COPY --from=icerleer/aisbase:latest /usr/local/freeswitch /usr/local/freeswitch

# set timezone
ENV TZ=Asia/Shanghai
# set file link
RUN ln -sf /usr/local/freeswitch/bin/freeswitch /usr/bin/ \
    && ln -sf /usr/local/freeswitch/bin/fs_cli /usr/bin/ \
    && ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone \
    && apt-get update && apt-get install -y locales \
    && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8 \
    && rm -rf /var/lib/apt/lists/*

# set language chat-set
ENV LANG en_US.utf8

# copy config
# RUN mv /usr/local/freeswitch/.conf /usr/local/freeswitch/conf

## Ports
# Open the container up to the world.
## 8021 ESL, 
## 5060 (SIP for default Internal Profile)
## 5080 (SIP for external Profile)
## 5070 (SIP for 'NAT' Profile)
## 16384-32768/udp (For RTP)
## 5066, 7443 (ws and wss)
## ESL port 21014
EXPOSE 21010/tcp 21010/udp

# Volumes
## Freeswitch Configuration 
VOLUME ["/usr/local/freeswitch/conf"]
## Tmp so we can get core dumps out
# VOLUME ["Tmp"]

# Limits Configuration
COPY  build/AiSwitch.limits.conf /etc/security/limits.d/freeswitch.limits.conf

# Healthcheck to make sure the service is running
SHELL       ["/bin/bash"]
HEALTHCHECK --interval=15s --timeout=5s \
    CMD  fs_cli -P21014 -p "long@123" -x status | grep -q ^UP || exit 1

# copy entrypoint
COPY docker-entrypoint.sh /
# set entrypoint
ENTRYPOINT ["/docker-entrypoint.sh"]
# set args
CMD ["freeswitch"]