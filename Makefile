MKFILE_DIR      := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
PARENT_MKFILE   := $(HOME)/.Makefile
GH_USER 		:= $(USER)
GH_REGISTRY 	:= ghcr.io/$(GH_USER)/docker-lib
GH_SECRET   	:= $(SECRETS_REPO)/files/github/gh_token.txt
DH_USER 		:= $(USER)
DH_SECRET   	:= $(SECRETS_REPO)/files/dockerhub/dh_secrets.txt
HOST_CODE_BASE	:= $(GITHUB)/$(USER)
RUN_OPTS        := --env-file=docker/docker.env --rm -it \
					-v $(HOST_CODE_BASE):/root/labs \
					-v $(HOME)/.aws:/root/.aws \
					-v $(SECRETS_REPO)/files/sops/sops-age-key.txt:/root/.sops-age-key.txt

include $(PARENT_MKFILE)

# Existing container data
N_CONTAINER_RUNNING := $(shell $(call getEnvProperty,CER) container ls -aq | wc -l)
N_IMAGES_LAYERS := $(shell $(call getEnvProperty,CER) image ls -q | wc -l)
# For tagging images uniquely by change
GIT_TAG := $(shell git rev-parse --verify HEAD --short=5)

.PHONY: update_parent_mkfile
update_parent_mkfile: ## Update Parent Makefile to be used 
update_parent_mkfile:
	cp $(PARENT_MKFILE) docker/asdf/

#https://refine.dev/blog/docker-build-args-and-env-vars/#using-env-file
.PHONY: check_docker_envFile
check_docker_envFile: ## Check for the required DockerEnf File environment variable
check_docker_envFile:
	$(call exitsFile,docker/docker.env)

.PHONY: docker-local-buildAndRun
docker-local-buildAndRun: ## Build and Run locally the Docker configuration (DF) passed as parameter. Usage: DF=asdf.ubuntu make docker-local-buildAndRun
docker-local-buildAndRun: check_docker_envFile check_envfile update_parent_mkfile
	$(call print_title,Build and Run $(shell echo $(call getEnvProperty,DF)) locally)
	$(call getEnvProperty,CER) build . --file docker/$(shell echo $(call getEnvProperty,DF))/$(shell echo $(call getEnvProperty,DF)).dockerfile --tag local.$(DH_USER)/$(shell echo $(call getEnvProperty,DF)):latest --tag local.$(DH_USER)/$(shell echo $(call getEnvProperty,DF)):$(GIT_TAG)
	$(call getEnvProperty,CER) run --name $(shell echo $(call getEnvProperty,DF))_$(shell echo $$RANDOM) $(RUN_OPTS) \
		-d local.$(DH_USER)/$(shell echo $(call getEnvProperty,DF)):latest

.PHONY: docker-dh-buildAndPush
docker-dh-buildAndPush: ## Build and Push to DockerHub the docker configuration (DF) passed as parameter. Usage: (DF)=asdf.ubuntumake docker-dh-buildAndPush
docker-dh-buildAndPush: check_docker_envFile check_envfile update_parent_mkfile
	$(call print_title,Build and Push $(shell echo $(call getEnvProperty,DF)) to DockerHub)
	cat $(DH_SECRET) | $(shell echo $(call getEnvProperty,CER)) login --username $(DH_USER) --password-stdin
	$(call getEnvProperty,CER) build --file docker/$(shell echo $(call getEnvProperty,DF))/$(shell echo $(call getEnvProperty,DF)).dockerfile --tag $(DH_USER)/$(shell echo$(call getEnvProperty,DF)).$(shell echo $(call getEnvProperty,LOCAL_BUILD_NODE)):latest --tag $(DH_USER)/$(shell echo $(call getEnvProperty,DF)).$(shell echo $(call getEnvProperty,LOCAL_BUILD_NODE)):$(GIT_TAG) .
	$(call getEnvProperty,CER) push $(DH_USER)/$(shell echo $(call getEnvProperty,DF)).$(shell echo $(call getEnvProperty,LOCAL_BUILD_NODE)):$(GIT_TAG)
	$(call getEnvProperty,CER) push $(DH_USER)/$(shell echo $(call getEnvProperty,DF)).$(shell echo $(call getEnvProperty,LOCAL_BUILD_NODE)):latest

.PHONY: docker-dh-run
docker-dh-run: ## Run a DockerHub Image (DHI) container passed as parameter. Usage: DHI=base.ubuntu make docker-dh-run
docker-dh-run: check_docker_envFile check_envfile
	$(call print_title,Run image $(call getEnvProperty,DHI) from DockerHub)
	$(call getEnvProperty,CER) run --name $(shell echo $(call getEnvProperty,DHI) | cut -d ":" -f 1)_$(shell echo $$RANDOM) \
		$(RUN_OPTS) \
		$(shell $(call getEnvProperty,EXTRA_RUN_OPTIONS)) \
		$(DH_USER)/$(shell echo $(call getEnvProperty,DHI))

.PHONY: docker-gh-run
docker-gh-run: ## Run a GitHub Image (GHI) container passed as parameter. Usage: GHI=base.ubuntu make docker-gh-run
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
	if [ $(N_CONTAINER_RUNNING) -gt 0 ]; then $(call getEnvProperty,CER) container stop $(shell $(call getEnvProperty,CER) container ls -aq) && $(call getEnvProperty,CER) container rm $(shell $(call getEnvProperty,CER) container ls -aq)); fi
	if [ $(N_IMAGES_LAYERS) -gt 0 ]; then $(call getEnvProperty,CER) image rm -f $(shell $(call getEnvProperty,CER) image ls -q); fi
	$(call getEnvProperty,CER) system prune --all --force --volumes

.PHONY: sast-scan-all
sast-scan-all: ## SAST scan from https://slscan.io/en/latest/ for the root
sast-scan-all:
	$(call print_title,SAST scan for the root)
	$(call getEnvProperty,CER) run --rm -e "WORKSPACE=$(PWD)" -v $(PWD):/app shiftleft/sast-scan scan --build
