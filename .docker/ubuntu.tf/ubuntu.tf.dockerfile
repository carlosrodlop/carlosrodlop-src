FROM ghcr.io/carlosrodlop/carlosrodlop-src.k8s:main

ENV IMAGE_ROOT_PATH=.docker/tf

WORKDIR /root

COPY ${IMAGE_ROOT_PATH}/.tool-versions .tool-versions-tf
RUN cat .tool-versions-tf >> .tool-versions && \
    source .asdf/asdf.sh && \
    asdf plugin add terraform && \
    asdf plugin add terraform-docs && \
    asdf plugin add checkov && \
    asdf plugin add infracost && \
    asdf install

# https://github.com/asdf-vm/asdf/issues/1115#issuecomment-995026427
RUN source /root/.asdf/asdf.sh && \
    rm -f /root/.asdf/shims/* && \
    asdf reshim

WORKDIR /root/labs