.PHONY: format rebuild update

HOSTNAME := $(shell hostname)

# Detect system type (Linux or Darwin)
SYS_TYPE := $(shell uname -s)

IS_ASAHI := $(findstring $(shell uname -r),asahi)

regenerate-keys:
	nix-shell -p sops --run "sops updatekeys secrets/*.yaml"

format:
	nix-shell -p alejandra --run 'alejandra *'

rebuild:
ifeq ($(SYS_TYPE),Linux)
	@echo "Rebuilding NixOS configuration..."
	sudo nixos-rebuild switch --flake .#$(HOSTNAME) --impure # TODO: only use impure if IS_ASAHI (firmware)
else ($(SYS_TYPE),Darwin)
	@echo "Rebuilding Darwin configuration..."
	darwin-rebuild switch --flake .#$(HOSTNAME)
endif

update:
	nix flake update
