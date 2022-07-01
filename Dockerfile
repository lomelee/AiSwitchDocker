FROM debian:bullseye
LABEL Allen lee <icerleer@qq.com>

RUN DEBIAN_FRONTEND=noninteractive \
    apt-get update \
    && apt-get -yq install --no-install-recommends \
    # git
    git \
    # build
    build-essential cmake automake autoconf 'libtool-bin|libtool' pkg-config \
    # general # erlang-dev
    libssl-dev zlib1g-dev libdb-dev unixodbc-dev libncurses5-dev libexpat1-dev libgdbm-dev bison  libtpl-dev libtiff5-dev uuid-dev \
    # core
    libpcre3-dev libedit-dev libsqlite3-dev libcurl4-openssl-dev nasm \
    # core codecs
    libogg-dev libspeex-dev libspeexdsp-dev \
    # mod_enum
    libldns-dev \
    # mod_python3
    # python3-dev \
    # mod_av
    libavformat-dev libswscale-dev libavresample-dev \
    # mod_lua
    liblua5.2-dev \
    # mod_opus
    libopus-dev \
    # mod_pgsql
    libpq-dev \
    # mod_sndfile
    libsndfile1-dev libflac-dev libogg-dev libvorbis-dev \
    # mod_shout(mp3)
    libshout3-dev libmpg123-dev libmp3lame-dev \
    # del cache
    && rm -rf /var/lib/apt/lists/*


RUN git clone https://github.com/lomelee/AiSwitch /usr/src/AiSwitch \
    && git clone https://github.com/signalwire/libks /usr/src/libs/libks \
    && git clone https://github.com/freeswitch/sofia-sip /usr/src/libs/sofia-sip \
    && git clone https://github.com/freeswitch/spandsp /usr/src/libs/spandsp


# build source 
RUN cd /usr/src/libs/libks && cmake . -DCMAKE_INSTALL_PREFIX=/usr -DWITH_LIBBACKTRACE=1 && make install \
    && cd /usr/src/libs/sofia-sip && ./bootstrap.sh && ./configure CFLAGS="-g -ggdb" --with-pic --with-glib=no --without-doxygen --disable-stun --prefix=/usr && make -j`nproc --all` && make install \
    && cd /usr/src/libs/spandsp && ./bootstrap.sh && ./configure CFLAGS="-g -ggdb" --with-pic --prefix=/usr && make -j`nproc --all` && make install \
    && chmod -R +x /usr/src/AiSwitch && cd /usr/src/AiSwitch && ./bootstrap.sh -j && ./configure && make -j`nproc` && make install

# set time locale
RUN apt-get update && apt-get install -y locales \
    && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8 \
    && rm -rf /var/lib/apt/lists/*
ENV LANG en_US.utf8

## Ports
# Open the container up to the world.
### 8021 fs_cli, 5060 5061 5080 5081 sip and sips, 64535-65535 rtp
EXPOSE 8021/tcp \ 
    5060/tcp 5060/udp 5080/tcp 5080/udp \
    5061/tcp 5061/udp 5081/tcp 5081/udp \
    7443/tcp \
    5070/udp 5070/tcp \
    64535-65535/udp \
    16384-32768/udp


# Volumes
## Freeswitch Configuration ## Tmp so we can get core dumps out
VOLUME ["/usr/local/freeswitch/conf"] \ 
    ["/tmp"]


# Limits Configuration
COPY  build/AiSwitch.limits.conf /etc/security/limits.d/freeswitch.limits.conf

# Healthcheck to make sure the service is running
# SHELL       ["/bin/bash"]
# HEALTHCHECK --interval=15s --timeout=5s \
#     CMD  /usr/local/freeswitch/bin/fs_cli -x status | grep -q ^UP || exit 1

# # copy entrypoint
# COPY docker-entrypoint.sh /
# # set entrypoint
# ENTRYPOINT ["/docker-entrypoint.sh"]
# # set args
# CMD ["freeswitch"]