.DEFAULT_GOAL   := help
SHELL           := /bin/bash
MAKEFLAGS       += --no-print-directory
MKFILE_DIR      := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
DOCKER_REGISTRY := ghcr.io/carlosrodlop/carlosrodlop-src
DOCKER_SECRET   := $(MKFILE_DIR)/../secrets/files/github/gh_token.txt
SOPS_KEY 	  	:= $(MKFILE_DIR)/../secrets/files/sops/sops-age-key.txt
DEC_KEY 	  	:= $(shell cat $(SOPS_KEY))
ENC_KEY	  	  	:= $(shell age-keygen -y $(SOPS_KEY))

.PHONY: docker-sast-scan-all
docker-sast-scan-all: ## SAST scan from https://slscan.io/en/latest/ for the root
docker-sast-scan-all:
	@docker run --rm -e "WORKSPACE=$(PWD)" -v $(PWD):/app shiftleft/sast-scan scan --build

.PHONY: docker-run-package
docker-run-package: ## Run the selected package passed as parameter. Usage: IMAGE=base make docker-run-package
docker-run-package: guard-IMAGE
	@cat $(DOCKER_SECRET) | docker login ghcr.io --username carlosrodlop --password-stdin
	@docker run --name devops_tools -it --rm \
        --mount type=bind,source="$(MKFILE_DIR)/forks",target=/root/labs \
        --mount type=bind,source="$(HOME)/.aws",target=/root/.aws \
        --mount type=bind,source="$(HOME)/.ssh",target=/root/.ssh \
        -v "$(MKFILE_DIR)"/.docker/$(IMAGE)/v_kube:/root/.kube/ \
		--platform linux/amd64 \
        $(DOCKER_REGISTRY).$(IMAGE):main

.PHONY: sops-create-key
sops-create-key: ## Set up key from encription with SOPS
sops-create-key:
ifneq ("$(wildcard $(SOPS_KEY))","")
	@echo "Sops key $(SOPS_KEY) exists"
else
	@age-keygen -o $(SOPS_KEY)
	@chmod 600 $(SOPS_KEY)
	@echo "New Sops key created $(SOPS_KEY)"
endif

.PHONY: sops-encription
sops-encription: ## Encript file with SOPS. Upload to GitHub
sops-encription:
	@cd $(MKFILE_DIR)/.docker/tf/v_kube && SOPS_AGE_RECIPIENTS=$(ENC_KEY) sops -e config > config.enc

.PHONY: sops-decription
sops-decription: ## Decript file with SOPS. Include them in .gitignore
sops-decription:
	@cd $(MKFILE_DIR)/.docker/tf/v_kube && SOPS_AGE_KEY=$(DEC_KEY) sops -d config.enc > config

####################
## Common targets
####################

.PHONY: help
help: ## Makefile Help Page
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n\nTargets:\n"} /^[\/\%a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-21s\033[0m %s\n", $$1, $$2 }' $(MAKEFILE_LIST) 2>/dev/null

.PHONY: guard-%
guard-%:
	@if [[ "${${*}}" == "" ]]; then echo "Environment variable $* not set"; exit 1; fi
