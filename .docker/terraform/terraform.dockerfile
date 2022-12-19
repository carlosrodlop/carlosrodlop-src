FROM ghcr.io/carlosrodlop/carlosrodlop-src.k8s:main AS base
SHELL ["/bin/bash", "-c"]

LABEL   maintainer="Carlos Rodriguez Lopez <it.carlosrodlop@gmail.com>" \
    version="1.1" \
    updated_at=2022-12-19

# Tooling
WORKDIR /root

ENV IMAGE_ROOT_PATH=.docker/terraform

COPY ${IMAGE_ROOT_PATH}/.tool-versions .tool-versions-tf
RUN cat ".tool-versions-tf" >> ~/.tool-versions
RUN source ~/.asdf/asdf.sh && \
    asdf plugin add terraform && \
    asdf plugin add terraform-docs && \
    asdf plugin add checkov && \
    asdf plugin add infracost && \
    asdf plugin add kubectx && \
    asdf install

# Place into the mount with the Project Code
WORKDIR /root/labs
