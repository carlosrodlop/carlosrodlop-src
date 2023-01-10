MKFILE_DIR      := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
PARENT_MKFILE   := $(MKFILE_DIR)/../Makefile
DOCKER_USER 	:= carlosrodlop
DOCKER_REGISTRY := ghcr.io/carlosrodlop/carlosrodlop-src
DOCKER_SECRET   := $(MKFILE_DIR)/../secrets/files/github/gh_token.txt

include $(PARENT_MKFILE)

.PHONY: docker-run-base-local
docker-run-local: ## Build and Run locally the docker base configuration. Usage: make docker-run-base-local
docker-run-local: 
	$(call print_title,Running base image locally)
	@docker build . --file .docker/base/base.dockerfile --tag localbuild.carlosrodlop-src.base:latest
	@docker run --name base_tools -it --rm \
        --mount type=bind,source="$(MKFILE_DIR)/forks",target=/root/labs \
        --mount type=bind,source="$(HOME)/.aws",target=/root/.aws \
		--mount type=bind,source="$(PARENT_MKFILE)",target=/root/.Makefile \
		--mount type=bind,source="$(SOPS_KEY)",target=/root/secrets/files/sops/sops-age-key.txt \
        $(DOCKER_REGISTRY).base:latest

.PHONY: docker-run-gh_package
docker-run-gh_package: ## Run the selected GH package passed as parameter. Usage: IMAGE=base make docker-run-package
docker-run-gh_package: guard-IMAGE
	$(call print_title,Running $(IMAGE) image)
	@cat $(DOCKER_SECRET) | docker login ghcr.io --username $(DOCKER_USER)  --password-stdin
	@docker run --pull=always --name $(IMAGE)_tools -it --rm \
        --mount type=bind,source="$(MKFILE_DIR)/forks",target=/root/labs \
        --mount type=bind,source="$(HOME)/.aws",target=/root/.aws \
		--mount type=bind,source="$(PARENT_MKFILE)",target=/root/.Makefile \
		--mount type=bind,source="$(SOPS_KEY)",target=/root/secrets/files/sops/sops-age-key.txt \
        -v "$(MKFILE_DIR)"/.docker/$(IMAGE)/v_kube:/root/.kube/ \
		--platform linux/amd64 \
        $(DOCKER_REGISTRY).$(IMAGE):main

.PHONY: sast-scan-all
sast-scan-all: ## SAST scan from https://slscan.io/en/latest/ for the root
sast-scan-all: 
	$(call print_title,SAST scan for the root)
	@docker run --rm -e "WORKSPACE=$(PWD)" -v $(PWD):/app shiftleft/sast-scan scan --build

.PHONY: sops-encription
sops-encription: ## Encript file with SOPS. Upload to GitHub
sops-encription: 
	$(call print_title,Encrypting via SOPS)
	@cd $(MKFILE_DIR)/.docker/tf/v_kube && SOPS_AGE_RECIPIENTS=$(ENC_KEY) sops -e config > config.enc

.PHONY: sops-decription
sops-decription: ## Decript file with SOPS. Include them in .gitignore
sops-decription:
	$(call print_title,Decrypting via SOPS)
	@cd $(MKFILE_DIR)/.docker/tf/v_kube && SOPS_AGE_KEY=$(DEC_KEY) sops -d config.enc > config
