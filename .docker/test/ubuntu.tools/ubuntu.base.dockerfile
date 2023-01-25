FROM ubuntu:20.04
RUN adduser --disabled-password --gecos "" myuser
RUN apt-get update && \
    apt-get install -y curl git
RUN su - myuser -c "curl -fsSL https://github.com/asdf-vm/asdf/raw/main/docs/install.sh | bash"
ENV PATH="/home/myuser/.asdf/shims:$PATH"
ENV PATH="/home/myuser/.asdf/bin:$PATH"
USER myuser
CMD ["/bin/bash"]