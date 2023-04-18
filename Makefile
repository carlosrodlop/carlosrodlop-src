MKFILE_DIR      := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
PARENT_MKFILE   := $(PARENT_REPO)/Makefile
GH_USER 		:= $(USER)
GH_REGISTRY 	:= ghcr.io/$(GH_USER)/docker-lib
GH_SECRET   	:= $(SECRETS_REPO)/files/github/gh_token.txt
DH_USER 		:= $(USER)
DH_SECRET   	:= $(SECRETS_REPO)/files/dockerhub/dh_secrets.txt
HOST_CODE_BASE	:= $(GITHUB)/$(USER)
RUN_OPTS        := --env-file=docker/docker.env --rm -it  \
		--cpus=4 --memory=16g --memory-reservation=14g \
		-v $(HOST_CODE_BASE):/root/labs \
		-v $(HOME)/.aws:/root/.aws \
		-v $(SECRETS_REPO)/files/sops/sops-age-key.txt:/root/.sops-age-key.txt \
		-v $(PARENT_MKFILE):/root/.Makefile

include $(PARENT_MKFILE)

# Existing container data
N_CONTAINER_RUNNING := $(shell $(call getEnvProperty,CER) container ls -aq | wc -l)
N_IMAGES_LAYERS := $(shell $(call getEnvProperty,CER) image ls -q | wc -l)
# For tagging images uniquely by change
GIT_TAG := $(shell git rev-parse --verify HEAD --short=5)

#https://refine.dev/blog/docker-build-args-and-env-vars/#using-env-file
.PHONY: check_docker_envFile
check_docker_envFile: ## Check for the required KUBECONFIG environment variable
check_docker_envFile:
ifneq ("$(wildcard docker/docker.env)","")
else
	@echo Error docker/docker.env file does not exist and it is required
	@exit 1
endif

.PHONY: docker-local-buildAndRun
docker-local-buildAndRun: ## Build and Run locally the Docker configuration (DF) pased as parameter. Usage: DF=asdf.ubuntu make docker-local-buildAndRun
docker-local-buildAndRun: check_docker_envFile check_envfile
	$(call print_title,Build and Run $(call getEnvProperty,DF) locally)
	$(call getEnvProperty,CER) build . --file docker/$(call getEnvProperty,DF)/$(call getEnvProperty,DF)dockerfile --tag local.$(DH_USER)/$(call getEnvProperty,DF):latest --tag local.$(DH_USER)/$(call getEnvProperty,DF):$(GIT_TAG)
	$(call getEnvProperty,CER) run --name $(call getEnvProperty,DF)_$(shell echo $$RANDOM) $(RUN_OPTS) \
		local.$(DH_USER)/$(call getEnvProperty,DF):latest

.PHONY: docker-dh-buildAndPush
docker-dh-buildAndPush: ## Build and Push to DockerHub the docker configuration (DF)pased as parameter. Usage: (DF)=asdf.ubuntumake docker-dh-buildAndPush
docker-dh-buildAndPush: check_envfile
	$(call print_title,Build and Push $(call getEnvProperty,DF) to DockerHub)
	cat $(DH_SECRET) | $(call getEnvProperty,CER) login --username $(DH_USER) --password-stdin
	$(call getEnvProperty,CER) build --file docker/$(call getEnvProperty,DF)/$(call getEnvProperty,DF).dockerfile --tag $(DH_USER)/$(call getEnvProperty,DF).$(LOCAL_BUILD_NODE):latest --tag $(DH_USER)/$(call getEnvProperty,DF).$(LOCAL_BUILD_NODE):$(GIT_TAG) .
	$(call getEnvProperty,CER) push $(DH_USER)/$(call getEnvProperty,DF).$(LOCAL_BUILD_NODE):$(shell git rev-parse --verify HEAD --short=5)
	$(call getEnvProperty,CER) push $(DH_USER)/$(call getEnvProperty,DF).$(LOCAL_BUILD_NODE):latest

.PHONY: docker-dh-run
docker-dh-run: ## Build a DockerHub Image (DHI) pased as parameter. Usage: DHI=base.ubuntu make docker-dh-run
docker-dh-run: check_docker_envFile check_envfile
	$(call print_title,Run image $(call getProperty,DHI) from DockerHub)
	$(call getProperty,CER) run --name $(shell echo $(call getProperty,DHI) | cut -d ":" -f 1)_$(shell echo $$RANDOM) \
		$(RUN_OPTS) \
		$(DH_USER)/$(shell echo $(call getProperty,DHI))

.PHONY: docker-gh-run
docker-gh-run: ## Build a GitHub Image (GHI) pased as parameter. Usage: GHI=base.ubuntu make docker-gh-run
docker-gh-run: check_docker_envFile check_envfile
	$(call print_title,Run image $(call getEnvProperty,GHI) from Github)
	@cat $(GH_SECRET) | $(call getEnvProperty,CER) login ghcr.io --username $(GH_USER)  --password-stdin
	$(call getEnvProperty,CER) run --name $(shell echo $(DHI) | cut -d ":" -f 1)_$(shell echo $$RANDOM) $(RUN_OPTS) \
		--platform linux/amd64 \
        $(GH_REGISTRY)/$(call getEnvProperty,GHI)

.PHONY: docker-compose-run
docker-compose-run: ## Run docker compose file. Usage: DCF=base.ubuntu make docker-compose-run
docker-compose-run: check_docker_envFile
	$(call print_title,Run Docker Compose $(call getEnvProperty,DCF))
	cd docker-compose/$(shell echo $(call getEnvProperty,DCF)) && docker-compose up -d

.PHONY: docker-total-clean
docker-total-clean: ## Fully clean all docker images and containers
docker-total-clean:
	$(call print_title,Purge docker)
	if [ $(N_CONTAINER_RUNNING) -gt 0 ]; then $(call getEnvProperty,CER) container stop $(shell $(call getEnvProperty,CER) container ls -aq) && $(call getEnvProperty,CER) container rm $(shell $(call getEnvProperty,CER) container ls -aq); fi
	if [ $(N_IMAGES_LAYERS) -gt 0 ]; then $(call getEnvProperty,CER) image rm -f $(shell $(call getEnvProperty,CER) image ls -q); fi
	$(call getEnvProperty,CER) system prune --all --force --volumes

.PHONY: sast-scan-all
sast-scan-all: ## SAST scan from https://slscan.io/en/latest/ for the root
sast-scan-all:
	$(call print_title,SAST scan for the root)
	$(call getEnvProperty,CER) run --rm -e "WORKSPACE=$(PWD)" -v $(PWD):/app shiftleft/sast-scan scan --build