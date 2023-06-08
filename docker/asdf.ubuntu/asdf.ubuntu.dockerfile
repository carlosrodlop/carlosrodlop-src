FROM ubuntu:20.04
SHELL ["/bin/bash", "-c"]

LABEL   maintainer="Carlos Rodriguez Lopez <it.carlosrodlop@gmail.com>"

#https://packages.ubuntu.com/
RUN apt-get update -y && \
    apt-get install -y --no-install-recommends software-properties-common && \
    apt-get install -y --no-install-recommends \
    # https://brain2life.hashnode.dev/how-to-install-pyenv-python-version-manager-on-ubuntu-2004
    make build-essential libssl-dev zlib1g-dev \
    libbz2-dev libreadline-dev libsqlite3-dev llvm \
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

ENV DOCKERFILE_PATH=docker/asdf.ubuntu \
    ASDF_VERSION=v0.10.2 \
    USER=root

WORKDIR /${USER}

COPY ${DOCKERFILE_PATH}/.zshrc .zshrc
COPY ${DOCKERFILE_PATH}/.profile .profile
COPY ${DOCKERFILE_PATH}/.tool-versions .tool-versions

RUN mkdir .antigen && \
    curl -L git.io/antigen > .antigen/antigen.zsh && \
    cat ".profile" >> ~/.zshrc

RUN git clone --depth 1 https://github.com/asdf-vm/asdf.git --branch ${ASDF_VERSION} .asdf && \
    source .asdf/asdf.sh && \
    asdf plugin add awscli && \
    asdf plugin add gcloud && \
    #asdf plugin add jq && \
    asdf plugin add python && \
    asdf plugin add java && \
    asdf plugin add age && \
    asdf plugin add eksctl && \
    asdf plugin add helm && \
    asdf plugin add helm-diff && \
    asdf plugin add helmfile && \
    asdf plugin add k9s && \
    asdf plugin add kubectl && \
    asdf plugin add velero && \
    asdf plugin add kubectx && \
    asdf plugin add terraform && \
    asdf plugin add terraform-docs && \
    asdf install && \
    #installaing yq from mikefarah
    #https://github.com/mikefarah/yq#latest-version
    wget https://github.com/mikefarah/yq/releases/latest/download/yq_linux_amd64 -O /usr/bin/yq && \
    chmod +x /usr/bin/yq && \
    #installing robusta cli
    pip install -U robusta-cli --no-cache

# https://github.com/asdf-vm/asdf/issues/1115#issuecomment-995026427
RUN source /${USER}/.asdf/asdf.sh && \
    rm -f /${USER}/.asdf/shims/* && \
    asdf reshim

WORKDIR /root/labs

ENTRYPOINT ["/bin/zsh"]
