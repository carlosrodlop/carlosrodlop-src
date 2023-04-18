# Docker Library

<p align="center">
  <img alt="docker-icon" src="https://visualpharm.com/assets/917/Docker-595b40b65ba036ed117d3f62.svg" height="160" />
  <p align="center">Welcome to my Docker Library, a storage place for my assets related to my journey around Containers' Land</p>
</p>

---

![GitHub Latest Release)](https://img.shields.io/github/v/release/carlosrodlop/terraform-lib?logo=github) ![GitHub Issues](https://img.shields.io/github/issues/carlosrodlop/docker-lib?logo=github) [![gitleaks badge](https://img.shields.io/badge/protected%20by-gitleaks-blue)](https://github.com/zricethezav/gitleaks#pre-commit) [![gitsecrets](https://img.shields.io/badge/protected%20by-gitsecrets-blue)](https://github.com/awslabs/git-secrets) [![anchore](https://img.shields.io/badge/scan%20by-anchore-blue)](https://github.com/anchore/scan-action)

Welcome to the Docker Library, my storage for reusable assets related to container engines.

* Since Docker runtime was deprecated in Kubernetes version 1.20 ([Kubernetes is deprecating Docker as a container runtime after v1.20.](https://kubernetes.io/blog/2020/12/02/dont-panic-kubernetes-and-docker/)), I made the `Makefile` to be compatible also with [containerd/nerdctl](https://github.com/containerd/nerdctl) container engine. (See [How To Replace Docker With nerdctl And Rancher Desktop - DevOps ToolKit](https://www.youtube.com/watch?v=evWPib0iNgY))

* Docker images are uploaded to the following registries via GitHub Actions:

  * [Github](https://github.com/carlosrodlop?tab=packages&repo_name=docker-labs)
  * [DockerHub](https://hub.docker.com/u/carlosrodlop)

* Copy the `.env.example` file to `.env` and edit the variables to your needs.
* To pass additional Environment Variables during the execution of the container use `.docker/docker.env` file.

## Image Catalog

### ASDF + ohmyz.sh

Image for my demos with nice [Oh My Zsh](https://ohmyz.sh/) and tool installation via [asdf](https://asdf-vm.com/)

* [![ASDF Alpine](https://github.com/carlosrodlop/docker-labs/actions/workflows/ci_asdf.alpine.ub.yaml/badge.svg)](https://github.com/carlosrodlop/carlosrodlop-src/actions/workflows/ci_asdf.alpine.ub.yaml)
* [![ASDF Ubuntu](https://github.com/carlosrodlop/docker-labs/actions/workflows/ci_asdf.ubuntu.ub.yaml/badge.svg)](https://github.com/carlosrodlop/carlosrodlop-src/actions/workflows/ci_asdf.ubuntu.ub.yaml)

### Stress and Stress-ng

Image for Load Testing including [stress](https://linux.die.net/man/1/stress) and [stress-ng](https://manpages.ubuntu.com/manpages/bionic/man1/stress-ng.1.html)

* [![Stress Ubuntu](https://github.com/carlosrodlop/docker-labs/actions/workflows/ci_stress.ubuntu.ub.yaml/badge.svg)](https://github.com/carlosrodlop/carlosrodlop-src/actions/workflows/ci_stress.ubuntu.ub.yaml)

### Osixia openldap + Data

Image for Ldap mock testing extending from [osixia/docker-openldap](https://github.com/osixia/docker-openldap). Ref [Build an OpenLDAP Docker Image That’s Populated With Users](https://betterprogramming.pub/ldap-docker-image-with-populated-users-3a5b4d090aa4)

* [![Oxia OpenLdap](https://github.com/carlosrodlop/docker-labs/actions/workflows/ci_ooldap.debian.ub/badge.svg)](https://github.com/carlosrodlop/carlosrodlop-src/actions/workflows/ci_ooldap.debian.ub.yaml)

Another type of implementation on [jenkins-infra/mock-ldap](https://github.com/jenkins-infra/mock-ldap)

## Awesome

![Awesome](https://cdn.rawgit.com/sindresorhus/awesome/d7305f38d29fed78fa85652e3a63e154dd8e8829/media/badge.svg)

* [Awesome Docker Repos](https://github.com/stars/carlosrodlop/lists/docker)
* [Docker - Awesome Software Architecture](https://awesome-architecture.com/devops/docker/docker/)
* [nerdctl/command-reference](https://github.com/containerd/nerdctl/blob/main/docs/command-reference.md)