FROM ghcr.io/carlosrodlop/carlosrodlop-src.base:main AS base
SHELL ["/bin/bash", "-c"]

LABEL   maintainer="Carlos Rodriguez Lopez <it.carlosrodlop@gmail.com>"

ENV IMAGE_ROOT_PATH=.docker/k8s

COPY ${IMAGE_ROOT_PATH}/.tool-versions .tool-versions-k8s
RUN cat .tool-versions-k8s >> .tool-versions
RUN source ~/.asdf/asdf.sh && \
    asdf plugin add eksctl && \
    asdf plugin add helm && \
    asdf plugin add helm-diff && \
    asdf plugin add helmfile && \
    asdf plugin add k9s && \
    asdf plugin add kubectl && \
    asdf plugin add velero && \
    asdf plugin add kubectx && \
    asdf install
