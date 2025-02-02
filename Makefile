.PHONY: format rebuild update

HOSTNAME := $(shell hostname)

# Detect system type (Linux or Darwin)
SYS_TYPE := $(shell uname -s)

format:
	nix-shell -p alejandra --run 'alejandra *'

rebuild:
ifeq ($(SYS_TYPE),Linux)
	@echo "Rebuilding NixOS configuration..."
	sudo nixos-rebuild switch --flake .#$(HOSTNAME)
else ($(SYS_TYPE),Darwin)
	@echo "Rebuilding Darwin configuration..."
	darwin-rebuild switch --flake .#$(HOSTNAME)
endif

update:
	nix flake update
