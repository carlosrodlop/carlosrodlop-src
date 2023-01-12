FROM alpine:latest
SHELL ["/bin/bash", "-l", "-c"]

RUN apk add --virtual .asdf-deps --no-cache bash curl git 
RUN adduser -s /bin/bash -h /asdf -D asdf

ENV PATH="${PATH}:/asdf/.asdf/shims:/asdf/.asdf/bin"

USER asdf
WORKDIR /asdf

COPY asdf-install-toolset /usr/local/bin

ONBUILD USER asdf
ONBUILD RUN git clone --depth 1 https://github.com/asdf-vm/asdf.git $HOME/.asdf && \
    echo -e '\n. $HOME/.asdf/asdf.sh' >> ~/.bashrc && \
    echo -e '\n. $HOME/.asdf/asdf.sh' >> ~/.profile && \
    source ~/.bashrc && \
    mkdir -p $HOME/.asdf/toolset