FROM ubuntu:22.04
SHELL ["/bin/bash", "-c"]

LABEL maintainer="Carlos Rodriguez Lopez <it.carlosrodlop@gmail.com>"

ENV DEBIAN_FRONTEND=noninteractive \
    DOCKERFILE_PATH=docker/swissknife.ubuntu \
    COMMON_PATH=docker/_common \
    ASDF_VERSION=v0.11.3 \
    YQ_VERSION=v4.35.2 \
    JQ_VERSION=jq-1.7 \
    USER=swiss-user \
    GROUP=swiss-group

ARG UID=1001
ARG GID=1001

#https://packages.ubuntu.com/
RUN apt-get update -y && \
    apt-get install -y --no-install-recommends git \
    # No gpg, https://stackoverflow.com/a/61692849 
    unzip \
    gnupg \
    gpg-agent \
    parallel \ 
    vim \
    wget \
    less \
    ca-certificates \
    openssh-client \
    wget \
    curl \
    make \
    # https://brain2life.hashnode.dev/how-to-install-pyenv-python-version-manager-on-ubuntu-2004
    build-essential libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev llvm libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

#https://nickjanetakis.com/blog/running-docker-containers-as-a-non-root-user-with-a-custom-uid-and-gid
RUN groupadd -g "${GID}" ${GROUP}  \
    && useradd --create-home --no-log-init -u "${UID}" -g "${GID}" ${USER}

USER ${USER}

WORKDIR /home/${USER}

COPY --chown=${USER}:${GROUP} ${DOCKERFILE_PATH}/.tool-versions .tool-versions
COPY --chown=${USER}:${GROUP} ${COMMON_PATH}/.bash_profile .bash_profile
COPY --chown=${USER}:${GROUP} ${COMMON_PATH}/.Makefile .Makefile

RUN echo "source .bash_profile" >> .bashrc && \
    cat <<EOF >> .bash_profile
#ASDF Configuration
PATH=/home/${USER}/.asdf/shims:/home/$USER/.asdf/bin:${PATH}
source /home/${USER}/.asdf/asdf.sh
# https://github.com/asdf-vm/asdf/issues/1115#issuecomment-995026427
rm -rf .asdf/shims/* && asdf reshim
EOF

RUN git clone --depth 1 https://github.com/asdf-vm/asdf.git --branch ${ASDF_VERSION} .asdf && \
    source .asdf/asdf.sh && \
    #https://github.com/asdf-vm/asdf/issues/276#issuecomment-907063520
    cut -d' ' -f1 .tool-versions|xargs -i asdf plugin add {} && \
    asdf install

# Not using asdf install because it is not working for required installations
ADD  --chmod=655 https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/yq_linux_amd64 /usr/bin/yq
ADD  --chmod=655 https://github.com/jqlang/jq/releases/download/${JQ_VERSION}/jq-linux64 /usr/bin/jq

ENTRYPOINT ["/bin/bash"]