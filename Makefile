MKFILE_DIR      := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
PARENT_MKFILE   := $(MKFILE_DIR)/../Makefile
DOCKER_REGISTRY := ghcr.io/carlosrodlop/carlosrodlop-src
DOCKER_SECRET   := $(MKFILE_DIR)/../secrets/files/github/gh_token.txt

include $(PARENT_MKFILE)

.PHONY: docker-sast-scan-all
docker-sast-scan-all: ## SAST scan from https://slscan.io/en/latest/ for the root
docker-sast-scan-all: 
	$(call print_title,SAST scan for the root)
	@docker run --rm -e "WORKSPACE=$(PWD)" -v $(PWD):/app shiftleft/sast-scan scan --build

.PHONY: docker-run-package
docker-run-package: ## Run the selected package passed as parameter. Usage: IMAGE=base make docker-run-package
docker-run-package: guard-IMAGE 
	$(call print_title,Running $(IMAGE) image)
	@cat $(DOCKER_SECRET) | docker login ghcr.io --username carlosrodlop --password-stdin
	@docker run --name devops_tools -it --rm \
        --mount type=bind,source="$(MKFILE_DIR)/forks",target=/root/labs \
        --mount type=bind,source="$(HOME)/.aws",target=/root/.aws \
		--mount type=bind,source="$(SOPS_KEY)",target=/root/.sops/sops-age-key.txt \
        -v "$(MKFILE_DIR)"/.docker/$(IMAGE)/v_kube:/root/.kube/ \
		--platform linux/amd64 \
        $(DOCKER_REGISTRY).$(IMAGE):main

.PHONY: sops-create-key
sops-create-key: ## Set up key from encription with SOPS
sops-create-key: 
	$(call print_title,Creating SOPS key)
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
	$(call print_title,Encrypting via SOPS)
	@cd $(MKFILE_DIR)/.docker/tf/v_kube && SOPS_AGE_RECIPIENTS=$(ENC_KEY) sops -e config > config.enc

.PHONY: sops-decription
sops-decription: ## Decript file with SOPS. Include them in .gitignore
sops-decription: 
	$(call print_title,Decrypting via SOPS)
	@cd $(MKFILE_DIR)/.docker/tf/v_kube && SOPS_AGE_KEY=$(DEC_KEY) sops -d config.enc > config
