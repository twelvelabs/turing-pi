.DEFAULT_GOAL := help
SHELL := /bin/bash


images/raspios.img.xz:
	mkdir -p ./images
	curl -fsSL "https://downloads.raspberrypi.org/raspios_lite_arm64/images/raspios_lite_arm64-2022-09-26/2022-09-22-raspios-bullseye-arm64-lite.img.xz" > ./images/raspios.img.xz

images/raspios.img: images/raspios.img.xz
	xz --decompress --keep ./images/raspios.img.xz

##@ App

.PHONY: download
download: images/raspios.img ## Download Raspberry Pi OS image
	@echo Image downloaded

.PHONY: flash
flash: image ## Flash and configure a compute module
	./bin/flash.sh

.PHONY: configure
configure: ## Configure a compute module
	./bin/configure.sh

.PHONY: clean
clean: ## Delete downloaded artifacts
	rm -Rf ./images/*


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
