MKFILE_DIR      := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
PARENT_MKFILE   := $(PARENT_REPO)/Makefile
GH_USER 		:= $(USER)
GH_REGISTRY 	:= ghcr.io/$(GH_USER)/docker-lib
GH_SECRET   	:= $(SECRETS_REPO)/files/github/gh_token.txt
DH_USER 		:= $(USER)
DH_SECRET   	:= $(SECRETS_REPO)/files/dockerhub/dh_secrets.txt
HOST_CODE_BASE	:= $(GITHUB)/$(USER)
RUN_OPTS        := --env-file=.docker/docker.env --rm -it  \
		--cpus=4 --memory=16g --memory-reservation=14g \
		-v $(HOST_CODE_BASE):/root/labs \
		-v $(HOME)/.aws:/root/.aws \
		-v $(SECRETS_REPO)/files/sops/sops-age-key.txt:/root/.sops-age-key.txt \
		-v $(PARENT_MKFILE):/root/.Makefile
# Tag suffix for the identify the machine type which build the image (m1 - Apple M1, m2 - Intel, ub - Ubuntu)
# For performance reasons, run the images in a host with the same architecture as the one used to build the image
# In you are running and Image built in a linux arch from m1 host --platform linux/amd64 is required. Despite it, the performance won't be good.
LOCAL_BUILD_NODE := m1
# Container Engine Runtime (docker, nerdctl)
CER := docker
# Existing container data
N_CONTAINER_RUNNING := $(shell $(CER) container ls -aq | wc -l)
N_IMAGES_LAYERS := $(shell $(CER) image ls -q | wc -l)
# For tagging images uniquely by change
GIT_TAG := $(shell git rev-parse --verify HEAD --short=5)
#.docker folder
DF  ?= asdf.ubuntu
#DockerHub image
DHI ?= asdf.ubuntu.m1
#GitHub Package image
GHI ?= asdf.ubuntu.ub

include $(PARENT_MKFILE)

#https://refine.dev/blog/docker-build-args-and-env-vars/#using-env-file
.PHONY: check_docker_envFile
check_docker_envFile: ## Check for the required KUBECONFIG environment variable
check_docker_envFile:
ifneq ("$(wildcard .docker/docker.env)","")
else
	@echo Error .docker/docker.env file does not exist and it is required
	@exit 1
endif

.PHONY: docker-local-buildAndRun
docker-local-buildAndRun: ## Build and Run locally the Docker configuration (DF) pased as parameter. Usage: DF=asdf.ubuntu make docker-local-buildAndRun
docker-local-buildAndRun: guard-DF check_docker_envFile
	$(call print_title,Build and Run $(DF) locally)
	$(CER) build . --file .docker/$(DF)/$(DF).dockerfile --tag local.$(DH_USER)/$(DF):latest --tag local.$(DH_USER)/$(DF):$(GIT_TAG)
	$(CER) run --name $(DF)_$(shell echo $$RANDOM) $(RUN_OPTS) \
		local.$(DH_USER)/$(DF):latest

.PHONY: docker-dh-buildAndPush
docker-dh-buildAndPush: ## Build and Push to DockerHub the docker configuration (DF)pased as parameter. Usage: (DF)=asdf.ubuntumake docker-dh-buildAndPush
docker-dh-buildAndPush: guard-DF check_docker_envFile
	$(call print_title,Build and Push $(DF) to DockerHub)
	cat $(DH_SECRET) | $(CER) login --username $(DH_USER) --password-stdin
	$(CER) build --file .docker/$(DF)/$(DF).dockerfile --tag $(DH_USER)/$(DF).$(LOCAL_BUILD_NODE):latest --tag $(DH_USER)/$(DF).$(LOCAL_BUILD_NODE):$(GIT_TAG) .
	$(CER) push $(DH_USER)/$(DF).$(LOCAL_BUILD_NODE):$(shell git rev-parse --verify HEAD --short=5)
	$(CER) push $(DH_USER)/$(DF).$(LOCAL_BUILD_NODE):latest

.PHONY: docker-dh-run
docker-dh-run: ## Build a DockerHub Image (DHI) pased as parameter. Usage: DHI=base.ubuntu make docker-dh-run
docker-dh-run: guard-DHI check_docker_envFile
	$(call print_title,Run image $(DHI) from DockerHub)
	$(CER) run --name $(shell echo $(DHI) | cut -d ":" -f 1)_$(shell echo $$RANDOM) \
		$(RUN_OPTS) \
		$(DH_USER)/$(DHI)

.PHONY: docker-gh-run
docker-gh-run: ## Build a GitHub Image (GHI) pased as parameter. Usage: GHI=base.ubuntu make docker-gh-run
docker-gh-run: guard-GHI check_docker_envFile
	$(call print_title,Run image $(GHI) from Github)
	@cat $(GH_SECRET) | nerdctl login ghcr.io --username $(GH_USER)  --password-stdin
	$(CER) run --name $(shell echo $(DHI) | cut -d ":" -f 1)_$(shell echo $$RANDOM) $(RUN_OPTS) \
		--platform linux/amd64 \
        $(DOCKER_REGISTRY)/$(GHI)

.PHONY: docker-total-clean
docker-total-clean: ## Fully clean all docker images and containers
docker-total-clean:
	$(call print_title,Purge docker)
	if [ $(N_CONTAINER_RUNNING) -gt 0 ]; then $(CER) container stop $(shell $(CER) container ls -aq) && $(CER) container rm $(shell $(CER) container ls -aq); fi
	if [ $(N_IMAGES_LAYERS) -gt 0 ]; then $(CER) image rm -f $(shell $(CER) image ls -q); fi
	$(CER) system prune --all --force --volumes

.PHONY: sast-scan-all
sast-scan-all: ## SAST scan from https://slscan.io/en/latest/ for the root
sast-scan-all:
	$(call print_title,SAST scan for the root)
	$(CER) run --rm -e "WORKSPACE=$(PWD)" -v $(PWD):/app shiftleft/sast-scan scan --build