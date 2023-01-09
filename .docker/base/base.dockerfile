FROM ubuntu:22.10 AS base
SHELL ["/bin/bash", "-c"]

LABEL   maintainer="Carlos Rodriguez Lopez <it.carlosrodlop@gmail.com>" \
    version="1.1.1" \
    updated_at=2023-01-09

ENV IMAGE_ROOT_PATH=.docker/base \
    ROOTLESS_USER=carlosrodlop \
    TZ=Europe/Madrid

#RUN useradd --create-home ${ROOTLESS_USER}

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
    curl \ 
    age && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir .antigen
RUN curl -L git.io/antigen > .antigen/antigen.zsh
COPY ${IMAGE_ROOT_PATH}/.zshrc .zshrc
COPY ${IMAGE_ROOT_PATH}/.profile .profile
RUN cat ".profile" >> ~/.zshrc

RUN git clone --depth 1 https://github.com/asdf-vm/asdf.git .asdf
COPY ${IMAGE_ROOT_PATH}/.tool-versions .tool-versions
RUN source ~/.asdf/asdf.sh && \
    asdf plugin add awscli && \
    asdf plugin add gcloud && \
    asdf plugin add jq && \
    asdf plugin add yq && \
    asdf plugin add python && \
    asdf install

#USER ${ROOTLESS_USER}

# Place into the mount with the Project Code
WORKDIR /root/labs

ENTRYPOINT ["/bin/zsh"]
