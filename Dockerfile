0.14.0.2/0.14.0.2
https://github.com/zcoinofficial/zcoin/releases/download/v0.14.0.2/zcoin-0.14.0.2
FROM debian:buster

ARG VERSION
ARG VERSION_BUILD
ENV USER_ID ${USER_ID:-1000}
ENV GROUP_ID ${GROUP_ID:-1000}

RUN groupadd -g ${GROUP_ID} zcoin \
      && useradd -u ${USER_ID} -g zcoin -s /bin/bash -m -d /zcoin zcoin

RUN apt-get update && apt-get -y upgrade && apt-get install -y wget ca-certificates gpg && \
  apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY checksum.sha256 /root

RUN set -x && \
      cd /root && \
  wget -q https://github.com/zcoinofficial/zcoin/releases/download/v${VERSION}/zcoin-${VERSION}-linux64.tar.gz && \
      cat checksum.sha256 | grep ${VERSION} | sha256sum -c  && \
  tar xvf zcoin-${VERSION}-linux64.tar.gz && \
  cd zcoin-${VERSION_BUILD} && \
  mv bin/* /usr/bin/ && \
  mv lib/* /usr/bin/ && \
  mv include/* /usr/bin/ && \
  mv share/* /usr/bin/ && \
  cd /root && \
  rm -Rf zcoin-${VERSION_BUILD} zcoin-${VERSION}-linux64.tar.gz

ENV GOSU_VERSION 1.7
RUN set -x \
      && apt-get install -y --no-install-recommends \
              ca-certificates \
      && wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture)" \
      && wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-$(dpkg --print-architecture).asc" \
      && export GNUPGHOME="$(mktemp -d)" \
      && gpg --keyserver ha.pool.sks-keyservers.net --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
      && gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu \
      && rm -r "$GNUPGHOME" /usr/local/bin/gosu.asc \
      && chmod +x /usr/local/bin/gosu \
      && gosu nobody true


VOLUME ["/zcoin"]
EXPOSE  8168 8888

WORKDIR /zcoin

COPY scripts/docker-entrypoint.sh /usr/local/bin/
ENTRYPOINT ["docker-entrypoint.sh"]