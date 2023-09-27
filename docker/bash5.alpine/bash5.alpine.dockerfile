# Reference:https://github.com/asdf-community/asdf-alpine/blob/master/Dockerfile
# Issue => /asdf/.asdf/lib/commands/command-exec.bash: line 28: /asdf/.asdf/installs/awscli/2.2.33/bin/aws: cannot execute: required file not found 
FROM bash:5.2.15-alpine3.18

LABEL   maintainer="Carlos Rodriguez Lopez <it.carlosrodlop@gmail.com>" 

#https://pkgs.alpinelinux.org/packages
RUN apk add --virtual .asdf-deps --no-cache bash curl git \
    patch gcc make g++ zlib-dev bzip2 libffi
SHELL ["/bin/bash", "-l", "-c"]

ENV DOCKERFILE_PATH=docker/bash5.alpine \
    COMMON_PATH=docker/common

RUN apk --no-cache add openjdk11 --repository=http://dl-cdn.alpinelinux.org/alpine/edge/community

RUN addgroup -S casc-group && adduser -S casc-user -G casc-group

USER casc-user
WORKDIR /home/casc-user
ADD  --chmod=655 https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 /usr/bin/yq
ADD  --chmod=655 https://github.com/jqlang/jq/releases/latest/download/jq-linux64 /usr/bin/jq

ENV CACHE_DIR=/tmp/pimt-cache \
    CACHE_BASE_DIR=/tmp/casc-plugin-dependency-calculation-cache \
    TARGET_BASE_DIR=/tmp/casc-plugin-dependency-calculation-target

COPY --chown=casc-user ${DOCKERFILE_PATH}/run.sh run.sh
COPY --chown=casc-user ${COMMON_PATH}/.profile .profile
COPY --chown=casc-user ${COMMON_PATH}/.Makefile .Makefile
