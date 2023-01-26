MKFILE_DIR      := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
PARENT_MKFILE   := $(PARENT_REPO)/Makefile
GH_USER 		:= carlosrodlop
GH_REGISTRY 	:= ghcr.io/carlosrodlop/docker-labs
GH_SECRET   	:= $(SECRETS_REPO)/files/github/gh_token.txt
DH_USER 		:= carlosrodlop
DH_SECRET   	:= $(SECRETS_REPO)/files/dockerhub/dh_secrets.txt
HOST_CODE_BASE	:= $(GITHUB)/$(USER)
RUN_OPTS        := --rm -it  \
		--cpus=4 --memory=16g --memory-reservation=14g \
		-v $(HOST_CODE_BASE):/root/labs:delegated \
		-v $(HOME)/.aws:/root/.aws:cached \
		-v $(PARENT_MKFILE):/root/.Makefile:cached
RUN_OPTS_ROOTLESS := --rm -it  \
		--cpus=4 --memory=16g --memory-reservation=14g \
		-v $(HOME)/.aws:/asdf/.aws:cached \
		-v $(PARENT_MKFILE):/asdf/.Makefile:cached
LOCAL_BUILD_NODE := m1

#DEFAULTS
DHI 			?= asdf.ubuntu.m1

include $(PARENT_MKFILE)

.PHONY: docker-local-buildAndRun
docker-local-buildAndRun: ## Build and Run locally the Docker configuration (DF) pased as parameter. Usage: DF=asdf.ubuntu make docker-local-buildAndRun
docker-local-buildAndRun: guard-DF
	$(call print_title,Build and Run $(DF) locally)
	docker build . --file .docker/$(DF)/$(DF).dockerfile --tag local.$(DH_USER)/$(DF):latest --tag local.$(DH_USER)/$(DF):$(shell git rev-parse --verify HEAD --short=5)
	docker run --name $(DF)_$(shell echo $$RANDOM) $(RUN_OPTS) \
		local.$(DH_USER)/$(DF):latest

.PHONY: docker-dh-buildAndPush
docker-dh-buildAndPush: ## Build and Push to DockerHub the docker configuration (DF)pased as parameter. Usage: (DF)=asdf.ubuntumake docker-dh-buildAndPush
docker-dh-buildAndPush: guard-DF
	$(call print_title,Build and Push $(DF) to DockerHub)
	docker build . --file .docker/$(IMAGE)/$(IMAGE).dockerfile --tag $(DH_USER)/$(IMAGE).$(LOCAL_BUILD_NODE):latest --tag $(DH_USER)/$(IMAGE).$(LOCAL_BUILD_NODE):$(shell git rev-parse --verify HEAD --short=5)
	cat $(DH_SECRET) | docker login --username $(DH_USER)  --password-stdin
	docker push $(DH_USER)/$(IMAGE).$(LOCAL_BUILD_NODE):latest

.PHONY: docker-dh-run
docker-dh-run: ## Build a DockerHub Image (DHI) pased as parameter. Usage: DHI=base.ubuntu make docker-dh-run
docker-dh-run: guard-DHI
	$(call print_title,Run image $(DHI) from DockerHub)
	docker run --name $(shell echo $(DHI) | cut -d ":" -f 1)_$(shell echo $$RANDOM) $(RUN_OPTS) \
		$(DH_USER)/$(DHI)

.PHONY: docker-gh-run
docker-gh-run: ## Build a GitHub Image (GHI) pased as parameter. Usage: GHI=base.ubuntu make docker-gh-run
docker-gh-run: guard-GHI
	$(call print_title,Run image $(GHI) from Github)
	@cat $(GH_SECRET) | docker login ghcr.io --username $(GH_USER)  --password-stdin
	docker run --name $(shell echo $(DHI) | cut -d ":" -f 1)_$(shell echo $$RANDOM) $(RUN_OPTS) \
		--platform linux/amd64 \
        $(DOCKER_REGISTRY)/$(GHI)

.PHONY: sast-scan-all
sast-scan-all: ## SAST scan from https://slscan.io/en/latest/ for the root
sast-scan-all:
	$(call print_title,SAST scan for the root)
	@docker run --rm -e "WORKSPACE=$(PWD)" -v $(PWD):/app shiftleft/sast-scan scan --build
