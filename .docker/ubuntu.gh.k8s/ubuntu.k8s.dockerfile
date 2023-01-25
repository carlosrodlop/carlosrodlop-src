FROM ghcr.io/carlosrodlop/carlosrodlop-src.base:main

ENV IMAGE_ROOT_PATH=.docker/ubuntu.gh.k8s

WORKDIR /root

COPY ${IMAGE_ROOT_PATH}/.tool-versions .tool-versions-k8s
RUN cat .tool-versions-k8s >> .tool-versions && \
    source .asdf/asdf.sh && \
    asdf plugin add eksctl && \
    asdf plugin add helm && \
    asdf plugin add helm-diff && \
    asdf plugin add helmfile && \
    asdf plugin add k9s && \
    asdf plugin add kubectl && \
    asdf plugin add velero && \
    asdf plugin add kubectx && \
    asdf install

# https://github.com/asdf-vm/asdf/issues/1115#issuecomment-995026427
RUN source /root/.asdf/asdf.sh && \
    rm -f /root/.asdf/shims/* && \
    asdf reshim

WORKDIR /root/labs