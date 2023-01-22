.DEFAULT_GOAL := help
SHELL := /bin/bash


##@ App

.PHONY: build
build: ## Build the code

.PHONY: clean
clean: ## Clean build artifacts


##@ Other

.PHONY: setup
setup: ## Bootstrap for local development
	brew bundle install
	git submodule update --init --recursive
	$(MAKE) -C usbboot

# Via https://www.thapaliya.com/en/writings/well-documented-makefiles/
# Note: The `##@` comments determine grouping
.PHONY: help
help: ## Display this help
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)
	@echo ""
