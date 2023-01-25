MKFILE_DIR      := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
PARENT_MKFILE   := $$PARENT_REPO/Makefile
GH_USER 		:= carlosrodlop
GH_REGISTRY 	:= ghcr.io/carlosrodlop/docker-labs
GH_SECRET   	:= $$SECRETS_REPO/files/github/gh_token.txt
DH_USER 		:= carlosrodlop
DH_SECRET   	:= $$SECRETS_REPO/files/dockerhub/dh_secrets.txt
TAG_BUILD_OS 	:= MacOS_M1

include $(PARENT_MKFILE)

.PHONY: docker-dh-buildAndPush
docker-dh-buildAndPush: ## Build and Run locally the docker configuration pased as parameter. Usage: IMAGE=base.ubuntu make docker-run-local
docker-dh-buildAndPush: guard-IMAGE
	$(call print_title,Running base image $(IMAGE) locally)
	docker build . --file .docker/$(IMAGE)/$(IMAGE).dockerfile --tag $(TAG_BUILD_OS) --tag $(DH_USER)/$(IMAGE):latest
	cat $(DH_SECRET) | docker login --username $(DH_USER)  --password-stdin
	docker $(DH_USER)/$(IMAGE):latest

.PHONY: docker-dh-run
docker-dh-run: ## Build and Run locally the docker configuration pased as parameter. Usage: IMAGE=base.ubuntu make docker-run-local
docker-dh-run: guard-IMAGE
	$(call print_title,Running base image $(IMAGE) locally)
	@docker build . --file .docker/$(IMAGE)/$(IMAGE).dockerfile --tag localbuild.carlosrodlop-src.$(IMAGE):latest
	@docker run --name base_tools -it --rm \
		--cpus=4 --memory=16g --memory-reservation=14g \
		-v $(MKFILE_DIR)/forks:/root/labs:delegated \
		-v $(HOME)/.aws:/root/.aws:cached \
		-v $(PARENT_MKFILE):/root/.Makefile:cached \
		-v $(SOPS_KEY):/root/secrets/files/sops/sops-age-key.txt:cached \
        localbuild.carlosrodlop-src.$(IMAGE):latest

.PHONY: docker-gh-run
docker-gh-run: ## Run the selected GH package passed as parameter. Usage: IMAGE=tf.ubuntu make docker-run-gh_package
docker-gh-run: guard-IMAGE
	$(call print_title,Running $(IMAGE) image)
	@cat $(GH_SECRET) | docker login ghcr.io --username $(DOCKER_USER)  --password-stdin
	@docker run --pull=always --name $(IMAGE)_tools -it --rm \
		--cpus=4 --memory=16g --memory-reservation=14g \
		-v $(MKFILE_DIR)/forks:/root/labs:delegated \
		-v $(HOME)/.aws:/root/.aws:cached \
		-v $(PARENT_MKFILE):/root/.Makefile:cached \
		-v $(SOPS_KEY):/root/secrets/files/sops/sops-age-key.txt:cached \
        -v "$(MKFILE_DIR)"/.docker/$(IMAGE)/v_kube:/root/.kube/ \
		--platform linux/amd64 \
        $(DOCKER_REGISTRY).$(IMAGE):main

.PHONY: sast-scan-all
sast-scan-all: ## SAST scan from https://slscan.io/en/latest/ for the root
sast-scan-all: 
	$(call print_title,SAST scan for the root)
	@docker run --rm -e "WORKSPACE=$(PWD)" -v $(PWD):/app shiftleft/sast-scan scan --build