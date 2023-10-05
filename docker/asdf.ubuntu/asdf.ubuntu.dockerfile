FROM ubuntu:20.04
SHELL ["/bin/bash", "-c"]

LABEL   maintainer="Carlos Rodriguez Lopez <it.carlosrodlop@gmail.com>"

ENV DEBIAN_FRONTEND=noninteractive \
    DOCKERFILE_PATH=docker/asdf.ubuntu \
    COMMON_PATH=docker/_common \
    ASDF_VERSION=v0.11.3 \
    USER=asdf-user \
    GROUP=asdf-group \
    YQ_VERSION=v4.35.2 \
    JQ_VERSION=jq-1.7

ARG UID=1000
ARG GID=1000

#https://packages.ubuntu.com/
RUN apt-get update -y && \
    apt-get install -y --no-install-recommends software-properties-common && \
    apt-get install -y --no-install-recommends \
    # https://brain2life.hashnode.dev/how-to-install-pyenv-python-version-manager-on-ubuntu-2004
    make build-essential libssl-dev zlib1g-dev \
    libbz2-dev libreadline-dev libsqlite3-dev llvm \
    libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev \
    git zsh zip unzip gnupg gpg-agent parallel vim wget less ca-certificates openssh-client curl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

#https://nickjanetakis.com/blog/running-docker-containers-as-a-non-root-user-with-a-custom-uid-and-gid
RUN groupadd -g "${GID}" ${GROUP}  \
    && useradd --create-home --no-log-init -u "${UID}" -g "${GID}" ${USER}

USER ${USER}

RUN mkdir /home/${USER}/.antigen && \
    curl -L git.io/antigen > /home/${USER}/.antigen/antigen.zsh && \
    cat /home/${USER}/.profile >> ~/.zshrc

WORKDIR /home/${USER}

COPY --chown=${USER}:${GROUP} ${DOCKERFILE_PATH}/.tool-versions .tool-versions

RUN git clone --depth 1 https://github.com/asdf-vm/asdf.git --branch ${ASDF_VERSION} .asdf && \
    source .asdf/asdf.sh && \
    asdf plugin add awscli && \
    asdf plugin add gcloud && \
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
    #installing robusta cli
    pip install -U robusta-cli --no-cache

# https://github.com/asdf-vm/asdf/issues/1115#issuecomment-995026427
RUN source .asdf/asdf.sh && \
    rm -f .asdf/shims/* && \
    asdf reshim

# Not using asdf install because it is not working for required installations
ADD  --chmod=655 https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/yq_linux_amd64 /usr/bin/yq
ADD  --chmod=655 https://github.com/jqlang/jq/releases/download/${JQ_VERSION}/jq-linux64 /usr/bin/jq

COPY --chown=${USER}:${GROUP} ${COMMON_PATH}/.profile .profile
COPY --chown=${USER}:${GROUP} ${COMMON_PATH}/.Makefile .Makefile
COPY --chown=${USER}:${GROUP} ${DOCKERFILE_PATH}/.zshrc .zshrc

ENTRYPOINT ["/bin/zsh"]
