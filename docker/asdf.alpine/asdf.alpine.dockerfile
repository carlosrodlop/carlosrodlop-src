# Reference:https://github.com/asdf-community/asdf-alpine/blob/master/Dockerfile
# Issue => /asdf/.asdf/lib/commands/command-exec.bash: line 28: /asdf/.asdf/installs/awscli/2.2.33/bin/aws: cannot execute: required file not found 
FROM alpine:3.17

LABEL   maintainer="Carlos Rodriguez Lopez <it.carlosrodlop@gmail.com>" 

#https://pkgs.alpinelinux.org/packages
RUN apk add --virtual .asdf-deps --no-cache bash curl git \
    patch gcc make g++ zlib-dev bzip2 libffi
SHELL ["/bin/bash", "-l", "-c"]

#RUN adduser -s /bin/bash -h /asdf -D asdf

USER root
WORKDIR /root

ENV DOCKERFILE_PATH=docker/asdf.alpine \
    COMMON_PATH=docker/asdf \
    ASDF_VERSION=v0.10.2 \
    PATH="${PATH}:/asdf/.asdf/shims:/asdf/.asdf/bin"

COPY ${DOCKERFILE_PATH}/.tool-versions .tool-versions

RUN git clone --depth 1 https://github.com/asdf-vm/asdf.git $HOME/.asdf && \
    echo -e '\n. $HOME/.asdf/asdf.sh' >> ~/.bashrc && \
    echo -e '\n. $HOME/.asdf/asdf.sh' >> ~/.profile && \
    source .asdf/asdf.sh && \
    asdf plugin add awscli && \
    asdf install

ENTRYPOINT ["/bin/bash"]

