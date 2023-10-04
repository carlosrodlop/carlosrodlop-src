FROM ubuntu:20.04

LABEL   maintainer="Carlos Rodriguez Lopez <it.carlosrodlop@gmail.com>" 

ENV USER=stress-user \
    GROUP=stress-group

ARG UID=1000
ARG GID=1000

RUN apt-get update && \
    apt-get install -y stress-ng stress && \
    rm -rf /var/lib/apt/lists/*

#https://nickjanetakis.com/blog/running-docker-containers-as-a-non-root-user-with-a-custom-uid-and-gid
RUN groupadd -g "${GID}" ${GROUP}  \
    && useradd --create-home --no-log-init -u "${UID}" -g "${GID}" ${USER}

USER ${USER}

ENTRYPOINT ["/bin/sh"]