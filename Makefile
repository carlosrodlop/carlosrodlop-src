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
LOCAL_BUILD_NODE := m1
N_CONTAINER_RUNNING := $(shell nerdctl container ls -aq | wc -l)
N_IMAGES_LAYERS := $(shell nerdctl image ls -q | wc -l)
#N_DANGLING_IMAGES_LAYERS := $(shell nerdctl images -f "dangling=true" -q | wc -l)

#DEFAULTS
DHI 			?= asdf.ubuntu.m1
DF        		?= asdf.ubuntu

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
	nerdctl build . --file .docker/$(DF)/$(DF).dockerfile --tag local.$(DH_USER)/$(DF):latest --tag local.$(DH_USER)/$(DF):$(shell git rev-parse --verify HEAD --short=5)
	nerdctl run --name $(DF)_$(shell echo $$RANDOM) $(RUN_OPTS) \
		local.$(DH_USER)/$(DF):latest

.PHONY: docker-dh-buildAndPush
docker-dh-buildAndPush: ## Build and Push to DockerHub the docker configuration (DF)pased as parameter. Usage: (DF)=asdf.ubuntumake docker-dh-buildAndPush
docker-dh-buildAndPush: guard-DF check_docker_envFile
	$(call print_title,Build and Push $(DF) to DockerHub)
	cat $(DH_SECRET) | nerdctl login --username $(DH_USER) --password-stdin
	nerdctl build --file .docker/$(DF)/$(DF).dockerfile --tag $(DH_USER)/$(DF).$(LOCAL_BUILD_NODE):latest --tag $(DH_USER)/$(DF).$(LOCAL_BUILD_NODE):$(shell git rev-parse --verify HEAD --short=5) .
	nerdctl push $(DH_USER)/$(DF).$(LOCAL_BUILD_NODE):$(shell git rev-parse --verify HEAD --short=5)
	nerdctl push $(DH_USER)/$(DF).$(LOCAL_BUILD_NODE):latest

.PHONY: docker-dh-run
docker-dh-run: ## Build a DockerHub Image (DHI) pased as parameter. Usage: DHI=base.ubuntu make docker-dh-run
docker-dh-run: guard-DHI check_docker_envFile
	$(call print_title,Run image $(DHI) from DockerHub)
	nerdctl run --name $(shell echo $(DHI) | cut -d ":" -f 1)_$(shell echo $$RANDOM) \
		$(RUN_OPTS) \
		$(DH_USER)/$(DHI)

.PHONY: docker-gh-run
docker-gh-run: ## Build a GitHub Image (GHI) pased as parameter. Usage: GHI=base.ubuntu make docker-gh-run
docker-gh-run: guard-GHI check_docker_envFile
	$(call print_title,Run image $(GHI) from Github)
	@cat $(GH_SECRET) | nerdctl login ghcr.io --username $(GH_USER)  --password-stdin
	nerdctl run --name $(shell echo $(DHI) | cut -d ":" -f 1)_$(shell echo $$RANDOM) $(RUN_OPTS) \
		--platform linux/amd64 \
        $(DOCKER_REGISTRY)/$(GHI)

.PHONY: docker-total-clean
docker-total-clean: ## Fully clean all docker images and containers
docker-total-clean:
	$(call print_title,Purge docker)
	if [ $(N_CONTAINER_RUNNING) -gt 0 ]; then nerdctl container stop $(shell nerdctl container ls -aq) && nerdctl container rm $(shell nerdctl container ls -aq); fi
	if [ $(N_IMAGES_LAYERS) -gt 0 ]; then nerdctl image rm -f $(shell nerdctl image ls -q); fi
	@#if [ $(N_DANGLING_IMAGES_LAYERS) -gt 0 ]; then nerdctl rmi -f $(shell nerdctl images -f "dangling=true" -q); fi 
	nerdctl system prune --all --force --volumes

.PHONY: sast-scan-all
sast-scan-all: ## SAST scan from https://slscan.io/en/latest/ for the root
sast-scan-all:
	$(call print_title,SAST scan for the root)
	@nerdctl run --rm -e "WORKSPACE=$(PWD)" -v $(PWD):/app shiftleft/sast-scan scan --build