.DEFAULT_GOAL := help
SHELL         := /bin/bash
MAKEFLAGS     += --no-print-directory
MKFILE_DIR    := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))

.PHONY:
docker-run-devops-tools: ## Run image from Dockerfile.devops
docker-run-devops-tools:
	@cat src/secrets/files/github/gh_token.txt | docker login ghcr.io --username carlosrodlop --password-stdin
	@docker run --name devops_tools -it --rm \
        --mount type=bind,source="$(MKFILE_DIR)/src",target=/root/labs \
        --mount type=bind,source="$(HOME)/.aws",target=/root/.aws \
        --mount type=bind,source="$(HOME)/.ssh",target=/root/.ssh \
        -v "$(MKFILE_DIR)"/.docker/devops/v_kube:/root/.kube/ \
        -v "$(MKFILE_DIR)"/.docker/devops/v_tmp:/tmp/ \
        -p 8080:8080 \
		--platform linux/amd64 \
        ghcr.io/carlosrodlop/carlosrodlop.devops:main

####################
## Common targets
####################

.PHONY: help
help: ## Makefile Help Page
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n\nTargets:\n"} /^[\/\%a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-21s\033[0m %s\n", $$1, $$2 }' $(MAKEFILE_LIST) 2>/dev/null

.PHONY: guard-%
guard-%:
	@if [[ "${${*}}" == "" ]]; then echo "Environment variable $* not set"; exit 1; fi
