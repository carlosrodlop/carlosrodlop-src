FROM ubuntu:trusty

RUN apt-get update && apt-get install -y stress-ng stress && rm -rf /var/lib/apt/lists/*

ENTRYPOINT ["/bin/sh"]