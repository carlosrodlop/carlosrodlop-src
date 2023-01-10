FROM ghcr.io/carlosrodlop/carlosrodlop-src.k8s:main AS base

ENV IMAGE_ROOT_PATH=.docker/tf

WORKDIR /root

COPY ${IMAGE_ROOT_PATH}/.tool-versions .tool-versions-tf
RUN cat .tool-versions-tf >> .tool-versions
RUN source .asdf/asdf.sh && \
    asdf plugin add terraform && \
    asdf plugin add terraform-docs && \
    asdf plugin add checkov && \
    asdf plugin add infracost && \
    asdf install

WORKDIR /root/labs