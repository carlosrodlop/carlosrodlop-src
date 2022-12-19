.DEFAULT_GOAL   := help
SHELL           := /bin/bash
MAKEFLAGS       += --no-print-directory
MKFILE_DIR      := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
DOCKER_REGISTRY := ghcr.io/carlosrodlop/carlosrodlop-src
DOCKER_SECRET   := $(MKFILE_DIR)/../secrets/files/github/gh_token.txt

.PHONY:
docker-run-tf-tools: ## Run image from Dockerfile.devops
docker-run-tf-tools:
	@cat $(DOCKER_SECRET) | docker login ghcr.io --username carlosrodlop --password-stdin
	@docker run --name devops_tools -it --rm \
        --mount type=bind,source="$(MKFILE_DIR)/forks",target=/root/labs \
        --mount type=bind,source="$(HOME)/.aws",target=/root/.aws \
        --mount type=bind,source="$(HOME)/.ssh",target=/root/.ssh \
        -v "$(MKFILE_DIR)"/.docker/devops/v_kube:/root/.kube/ \
        -v "$(MKFILE_DIR)"/.docker/devops/v_tmp:/tmp/ \
		--platform linux/amd64 \
        $(DOCKER_REGISTRY).tf:main

####################
## Common targets
####################

.PHONY: help
help: ## Makefile Help Page
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n\nTargets:\n"} /^[\/\%a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-21s\033[0m %s\n", $$1, $$2 }' $(MAKEFILE_LIST) 2>/dev/null

.PHONY: guard-%
guard-%:
	@if [[ "${${*}}" == "" ]]; then echo "Environment variable $* not set"; exit 1; fi
