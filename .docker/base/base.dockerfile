FROM ubuntu:20.04 AS base
SHELL ["/bin/bash", "-c"]

LABEL   maintainer="Carlos Rodriguez Lopez <it.carlosrodlop@gmail.com>"

ENV IMAGE_ROOT_PATH=.docker/base \
    GROUP=devops \
    USER=carlosrodlop

RUN apt-get update -y && \
    # Installation additional repositories
    apt-get install -y software-properties-common && \
    add-apt-repository ppa:deadsnakes/ppa && \
    apt-get update -y && \
    # Installation common tools
    apt-get install -y --no-install-recommends \
    # https://brain2life.hashnode.dev/how-to-install-pyenv-python-version-manager-on-ubuntu-2004
    make build-essential libssl-dev zlib1g-dev \
    libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm \
    libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev \
    git \
    zsh \
    unzip \
    gnupg \
    gpg-agent \
    parallel \
    vim \
    wget \
    less \
    ca-certificates \
    openssh-client \
    curl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN adduser --system --group --create-home ${USER}
USER ${USER}
WORKDIR /home/${USER}

RUN mkdir .antigen
RUN curl -L git.io/antigen > .antigen/antigen.zsh
COPY ${IMAGE_ROOT_PATH}/.zshrc .zshrc
COPY ${IMAGE_ROOT_PATH}/.profile .profile
RUN cat /home/${USER}/.profile >> .zshrc

RUN git clone --depth 1 https://github.com/asdf-vm/asdf.git .asdf
COPY ${IMAGE_ROOT_PATH}/.tool-versions .tool-versions
RUN source .asdf/asdf.sh && \
    asdf plugin add awscli && \
    asdf plugin add gcloud && \
    asdf plugin add jq && \
    asdf plugin add yq && \
    asdf plugin add python && \
    asdf plugin add age && \
    asdf install

ENTRYPOINT ["/bin/zsh"]