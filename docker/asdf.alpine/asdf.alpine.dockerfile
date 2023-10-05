# Reference:https://github.com/asdf-community/asdf-alpine/blob/master/Dockerfile
# Issue => /asdf/.asdf/lib/commands/command-exec.bash: line 28: /asdf/.asdf/installs/awscli/2.2.33/bin/aws: cannot execute: required file not found 
FROM alpine:3.17

LABEL   maintainer="Carlos Rodriguez Lopez <it.carlosrodlop@gmail.com>" 

ENV DOCKERFILE_PATH=docker/asdf.alpine \
    COMMON_PATH=docker/_common \
    ASDF_VERSION=v0.10.2 \
    USER=asdf

#https://pkgs.alpinelinux.org/packages
RUN apk add --virtual .asdf-deps --no-cache bash curl git \
    patch gcc make g++ zlib-dev bzip2 libffi
SHELL ["/bin/bash", "-l", "-c"]

RUN adduser -s /bin/bash -h /home/${USER} -D ${USER}

USER ${USER}
WORKDIR /home/${USER}

ENV PATH="${PATH}:/home/${USER}/.asdf/shims:/home/${USER}/.asdf/bin"

COPY --chown=${USER} ${DOCKERFILE_PATH}/.tool-versions .tool-versions

RUN git clone --depth 1 https://github.com/asdf-vm/asdf.git $HOME/.asdf && \
    source .asdf/asdf.sh && \
    asdf plugin add awscli && \
    asdf install
