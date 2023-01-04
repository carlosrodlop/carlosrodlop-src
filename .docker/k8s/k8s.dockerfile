FROM ghcr.io/carlosrodlop/carlosrodlop-src.base:main AS base
SHELL ["/bin/bash", "-c"]

LABEL maintainer="Carlos Rodriguez Lopez <it.carlosrodlop@gmail.com>" \
    version="1.1" \
    updated_at=2022-12-19

# Tooling
WORKDIR /root

ENV HD_BIND=0.0.0.0 \
    IMAGE_ROOT_PATH=.docker/k8s

COPY ${IMAGE_ROOT_PATH}/.tool-versions .tool-versions-k8s
RUN cat ".tool-versions-k8s" >> .tool-versions
RUN source ~/.asdf/asdf.sh && \
    asdf plugin add helm && \
    asdf plugin add helm-diff && \
    asdf plugin add helmfile && \
    asdf plugin add k9s && \
    asdf plugin add kubectl && \
    asdf plugin add velero && \
    asdf plugin add kubectx && \
    asdf install && \
    helm plugin install https://github.com/komodorio/helm-dashboard.git

# Place into the mount with the Project Code
WORKDIR /root/labs
