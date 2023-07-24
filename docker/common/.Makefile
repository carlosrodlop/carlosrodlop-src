############################################################
## Parent Makefile
## It containts a library of target and methods
############################################################

.DEFAULT_GOAL   	:= help
SHELL           	:= /bin/bash
MAKEFLAGS       	+= --no-print-directory

define print_title
	@echo "# $(1) #"
endef

define print_subtitle
	@echo "## $(1) ##"
endef

define ask_confirmation
	@read -n 1 -r -s -p "Press any key to continue if you wish to $(1)..."
endef

define getTFValue
	$(shell terraform -chdir=$(1) output --raw $(2) | xargs)
endef

define getEnvProperty
	$(shell cat .env | grep $(1) | cut -d'=' -f2 | xargs)
endef

define exitsEnvVariable
	@if [ -z $(1) ]; then echo ERROR: Required Environment variable $(1) isn\'t defined. Example: $(2); exit 1; fi
endef

define exitsFile
	@if [ ! -f $(1) ]; then echo ERROR: $(1) file does not exist and it is required; exit 1; fi
endef

#https://kubernetes.io/docs/concepts/configuration/organize-cluster-access-kubeconfig/#the-kubeconfig-environment-variable
.PHONY: check_kubeconfig
check_kubeconfig: ## Check for the required KUBECONFIG environment variable
check_kubeconfig:
	$(call exitsEnvVariable,KUBECONFIG,export KUBECONFIG=/path/to/kubeconfig.yaml)
	$(call exitsFile,$$KUBECONFIG)

.PHONY: check_envfile
check_envfile: ## Check for the required .env file
check_envfile:
	$(call exitsFile,.env)

.PHONY: help
help: ## Makefile Help Page
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n\nTargets:\n"} /^[\/\%a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-21s\033[0m %s\n", $$1, $$2 }' $(MAKEFILE_LIST) 2>/dev/null

.PHONY: guard-%
guard-%:
	@if [[ "${${*}}" == "" ]]; then echo "Environment variable $* not set"; exit 1; fi
