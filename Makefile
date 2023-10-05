MKFILE_DIR      := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
PARENT_MKFILE   := docker/_common/.Makefile

include $(PARENT_MKFILE)

DBUILD_ARCH := $(shell echo $(call getEnvProperty,DBUILD_ARCH))
CER := $(shell echo $(call getEnvProperty,CER))
DF := $(shell echo $(call getEnvProperty,DF))
DCF := $(shell echo $(call getEnvProperty,DCF))
DH_ORG := $(shell echo $(call getEnvProperty,DH_ORG))
DH_SECRET := $(shell echo $(call getEnvProperty,DH_SECRET))
GH_ORG := $(shell echo $(call getEnvProperty,GH_ORG))
GH_REGISTRY := $(shell echo $(call getEnvProperty,GH_REGISTRY)) 
GH_SECRET := $(shell echo $(call getEnvProperty,GH_SECRET))
RUN_OPTS  := --env-file=docker/docker.env --rm -it \
			$(shell echo $(call getEnvProperty,RUN_OPTS))

#DockerHub image. Ref https://hub.docker.com/u/carlosrodlop (e.g. asdf.ubuntu.m1, stress.ubuntu.ub)
DHI := $(DF).$(DBUILD_ARCH)
#GitHub Package image
GHI := $(DHI):main
# Existing container data
N_CONTAINER_RUNNING := $(shell $(CER) container ls -aq | wc -l)
N_IMAGES_LAYERS := $(shell $(CER) image ls -q | wc -l)
# For tagging images uniquely by change
GIT_TAG := $(shell git rev-parse --verify HEAD --short=5)

#https://refine.dev/blog/docker-build-args-and-env-vars/#using-env-file
.PHONY: check_docker_envFile
check_docker_envFile: ## Check for the required DockerEnf File environment variable
check_docker_envFile:
	$(call exitsFile,docker/docker.env)

.PHONY: docker-local-buildAndRun
docker-local-buildAndRun: ## Build and Run locally the docker configuration (DF) passed as parameter. Usage: DF=asdf.ubuntu make docker-local-buildAndRun
docker-local-buildAndRun: check_docker_envFile check_envfile
	$(call print_title,Build and Run $(DF) locally)
	$(CER) build . --file docker/$(DF)/$(DF).dockerfile --tag local.$(DH_ORG)/$(DF):latest --tag local.$(DH_ORG)/$(DF):$(GIT_TAG)
	$(CER) run --name $(DF)_$(shell echo $$RANDOM) \
		$(RUN_OPTS) \
		local.$(DH_ORG)/$(DF)

.PHONY: docker-dh-buildAndPush
docker-dh-buildAndPush: ## Build and Push to DockerHub the docker configuration (DF) passed as parameter. Usage: (DF)=asdf.ubuntu make docker-dh-buildAndPush
docker-dh-buildAndPush: check_docker_envFile check_envfile
	$(call print_title,Build and Push $(DF) to DockerHub)
	@cat $(DH_SECRET) | $(shell echo $(CER) login --username $(DH_ORG) --password-stdin)
	$(CER) build . --file docker/$(DF)/$(DF).dockerfile --tag $(DH_ORG)/$(DF).$(DBUILD_ARCH):latest --tag $(DH_ORG)/$(DF).$(DBUILD_ARCH):$(GIT_TAG)
	$(CER) push $(DH_ORG)/$(DF).$(DBUILD_ARCH):$(GIT_TAG)
	$(CER) push $(DH_ORG)/$(DF).$(DBUILD_ARCH):latest

.PHONY: docker-dh-run
docker-dh-run: ## Run a DockerHub Image (DHI) container passed as parameter. Usage: DHI=base.ubuntu make docker-dh-run
docker-dh-run: check_docker_envFile check_envfile
	$(call print_title,Run image $(DHI) from DockerHub)
	$(CER) run --name $(shell echo $(DHI) | cut -d ":" -f 1)_$(shell echo $$RANDOM) \
		$(RUN_OPTS) \
		$(DH_ORG)/$(DHI)

.PHONY: docker-gh-run
docker-gh-run: ## Run a GitHub Image (GHI) container passed as parameter. Usage: GHI=base.ubuntu make docker-gh-run
docker-gh-run: check_docker_envFile check_envfile
	$(call print_title,Run image $(GHI) from Github)
	@cat $(GH_SECRET) | $(CER) login ghcr.io --username $(GH_ORG) --password-stdin
	$(CER) run --name $(shell echo $(GHI) | cut -d ":" -f 1)_$(shell echo $$RANDOM) \
		$(RUN_OPTS) \
        $(GH_REGISTRY)/$(GHI)

.PHONY: docker-compose-run
docker-compose-run: ## Run docker compose file. Usage: DCF=base.ubuntu make docker-compose-run
docker-compose-run: check_docker_envFile
	$(call print_title,Run Docker Compose $(DCF))
	cd docker-compose/$(DCF) && docker-compose up -d

.PHONY: docker-total-clean
docker-total-clean: ## Fully clean all docker images and containers
docker-total-clean:
	$(call print_title,Purge docker)
	if [ $(N_CONTAINER_RUNNING) -gt 0 ]; then $(CER) container stop $(shell $(CER) container ls -aq) || true && $(CER) container rm $(shell $(CER) container ls -aq) || true; fi
	if [ $(N_IMAGES_LAYERS) -gt 0 ]; then $(CER) image rm -f $(shell $(CER) image ls -q) || true; fi
	$(CER) system prune --all --force || true
	$(CER) volume prune --all --force || true

.PHONY: sast-scan-all
sast-scan-all: ## SAST scan from https://slscan.io/en/latest/ for the root
sast-scan-all:
	$(call print_title,SAST scan for the root)
	$(CER) run --rm -e "WORKSPACE=$$PWD" -v $$PWD:/app shiftleft/sast-scan scan --build
