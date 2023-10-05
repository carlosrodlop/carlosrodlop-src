# Reference:https://github.com/asdf-community/asdf-alpine/blob/master/Dockerfile
# Issue => /asdf/.asdf/lib/commands/command-exec.bash: line 28: /asdf/.asdf/installs/awscli/2.2.33/bin/aws: cannot execute: required file not found 
FROM bash:5.2.15-alpine3.18

LABEL   maintainer="Carlos Rodriguez Lopez <it.carlosrodlop@gmail.com>" 

#https://pkgs.alpinelinux.org/packages
RUN apk add --virtual .asdf-deps --no-cache bash curl git \
    patch gcc make g++ zlib-dev bzip2 libffi
SHELL ["/bin/bash", "-l", "-c"]

ENV DOCKERFILE_PATH=docker/bash5.alpine \
    CCOMMON_PATH=docker/_common \
    USER=casc-user \
    GROUP=casc-group

ARG UID=1000
ARG GID=1000

RUN apk --no-cache add openjdk11 --repository=http://dl-cdn.alpinelinux.org/alpine/edge/community

#https://gist.github.com/utkuozdemir/3380c32dfee472d35b9c3e39bc72ff01
RUN addgroup -g ${GID} ${GROUP} && \
    adduser --shell /sbin/nologin --disabled-password \
    --uid ${UID} --ingroup ${GROUP} ${USER}

USER ${USER}
WORKDIR /home/${USER}
ADD  --chmod=655 https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 /usr/bin/yq
ADD  --chmod=655 https://github.com/jqlang/jq/releases/latest/download/jq-linux64 /usr/bin/jq

ENV CACHE_DIR=/tmp/pimt-cache \
    CACHE_BASE_DIR=/tmp/casc-plugin-dependency-calculation-cache \
    TARGET_BASE_DIR=/tmp/casc-plugin-dependency-calculation-target

COPY --chown=${USER}:${GROUP} ${DOCKERFILE_PATH}/run.sh run.sh
COPY --chown=${USER}:${GROUP} ${COMMON_PATH}/.profile .profile
COPY --chown=${USER}:${GROUP} ${COMMON_PATH}/.Makefile .Makefile
