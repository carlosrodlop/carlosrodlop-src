FROM ghcr.io/carlosrodlop/carlosrodlop-src.k8s:main AS base
SHELL ["/bin/bash", "-c"]

LABEL   maintainer="Carlos Rodriguez Lopez <it.carlosrodlop@gmail.com>" 

# Tooling
WORKDIR /root

ENV IMAGE_ROOT_PATH=.docker/tf

COPY ${IMAGE_ROOT_PATH}/.tool-versions .tool-versions-tf
RUN cat ".tool-versions-tf" >> .tool-versions
RUN source ~/.asdf/asdf.sh && \
    asdf plugin add terraform && \
    asdf plugin add terraform-docs && \
    asdf plugin add checkov && \
    asdf plugin add infracost && \
    asdf install

# Place into the mount with the Project Code
WORKDIR /root/labs
