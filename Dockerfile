FROM debian:bullseye
MAINTAINER Allen lee <icerleer@qq.com>

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get -yq install git

RUN git clone https://github.com/lomelee/AiSwitch /usr/src/AiSwitch
RUN git clone https://github.com/signalwire/libks /usr/src/libs/libks
RUN git clone https://github.com/freeswitch/sofia-sip /usr/src/libs/sofia-sip
RUN git clone https://github.com/freeswitch/spandsp /usr/src/libs/spandsp

RUN DEBIAN_FRONTEND=noninteractive apt-get -yq install \
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
#     python3-dev \
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
    libshout3-dev libmpg123-dev libmp3lame-dev 


# build source 
RUN cd /usr/src/libs/libks && cmake . -DCMAKE_INSTALL_PREFIX=/usr -DWITH_LIBBACKTRACE=1 && make install
RUN cd /usr/src/libs/sofia-sip && ./bootstrap.sh && ./configure CFLAGS="-g -ggdb" --with-pic --with-glib=no --without-doxygen --disable-stun --prefix=/usr && make -j`nproc --all` && make install
RUN cd /usr/src/libs/spandsp && ./bootstrap.sh && ./configure CFLAGS="-g -ggdb" --with-pic --prefix=/usr && make -j`nproc --all` && make install

RUN cd /usr/src/AiSwitch && chmod a+x ./bootstrap.sh && ./bootstrap.sh -j
RUN cd /usr/src/AiSwitch && ./configure
RUN cd /usr/src/AiSwitch && make -j`nproc` && make install


# explicitly set user/group IDs
RUN groupadd -r freeswitch --gid=999 && useradd -r -g freeswitch --uid=999 freeswitch

# grab gosu for easy step-down from root
RUN apt-get update && apt-get install -y --no-install-recommends dirmngr gnupg2 ca-certificates wget \
    && gpg2 --keyserver hkp://keyserver.ubuntu.com --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
    && gpg2 --keyserver hkp://keyserver.ubuntu.com --recv-keys 655DA1341B5207915210AFE936B4249FA7B0FB03 \
    && gpg2 --output /usr/share/keyrings/signalwire-freeswitch-repo.gpg --export 655DA1341B5207915210AFE936B4249FA7B0FB03 \
    && rm -rf /var/lib/apt/lists/* \
    && wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/1.2/gosu-$(dpkg --print-architecture)" \
    && wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/1.2/gosu-$(dpkg --print-architecture).asc" \
    && gpg --verify /usr/local/bin/gosu.asc \
    && rm /usr/local/bin/gosu.asc \
    && chmod +x /usr/local/bin/gosu \
    && apt-get purge -y --auto-remove ca-certificates wget dirmngr gnupg2

# make the "en_US.UTF-8" locale so freeswitch will be utf-8 enabled by default
RUN apt-get update && apt-get install -y locales \
    && localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG en_US.utf8

# Cleanup build tools
RUN apt-get purge -y --auto-remove git build-essential cmake automake autoconf pkg-config 'libtool-bin|libtool'

# Cleanup other package
RUN apt-get autoremove

# Cleanup the image
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# cleanup source files
RUN rm -rf /usr/src/*


## Ports
# Open the container up to the world.
### 8021 fs_cli, 5060 5061 5080 5081 sip and sips, 64535-65535 rtp
EXPOSE 8021/tcp
EXPOSE 5060/tcp 5060/udp 5080/tcp 5080/udp
EXPOSE 5061/tcp 5061/udp 5081/tcp 5081/udp
EXPOSE 7443/tcp
EXPOSE 5070/udp 5070/tcp
EXPOSE 64535-65535/udp
EXPOSE 16384-32768/udp


# Volumes
## Freeswitch Configuration
VOLUME ["/usr/local/freeswitch/conf"]
## Tmp so we can get core dumps out
VOLUME ["/tmp"]


# Limits Configuration
COPY    build/AiSwitch.limits.conf /etc/security/limits.d/freeswitch.limits.conf

# Healthcheck to make sure the service is running
SHELL       ["/bin/bash"]
HEALTHCHECK --interval=15s --timeout=5s \
    CMD  /usr/local/freeswitch/bin/fs_cli -x status | grep -q ^UP || exit 1

# copy entrypoint
COPY docker-entrypoint.sh /
# set entrypoint
ENTRYPOINT ["/docker-entrypoint.sh"]

# set args
CMD ["freeswitch"]