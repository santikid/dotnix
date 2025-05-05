.PHONY: all format rebuild update regenerate-keys upgrade

HOSTNAME := $(shell hostname)

# Detect system type (Linux or Darwin)
SYS_TYPE := $(shell uname -s)

all:
	@echo "no command supplied (all/format/rebuild/update/regenerate-keys/upgrade)"

rekey:
	gpg --recv-keys 644EFF248A9CA2D269C30A7A6AA809E3B3CCCA64
	nix-shell -p sops --run "sops updatekeys secrets/*.yaml"

format:
	nix-shell -p alejandra --run 'alejandra *'
	nix-shell -p stylua --run 'stylua -g "*.lua" -- .'

rebuild:
ifeq ($(SYS_TYPE),Linux)
	@echo "Rebuilding NixOS configuration..."
	sudo nixos-rebuild switch --flake .#$(HOSTNAME)
endif
ifeq ($(SYS_TYPE),Darwin)
	@echo "Rebuilding Darwin configuration..."
	darwin-rebuild switch --flake .#$(HOSTNAME)
endif

update:
	nix flake update

upgrade: update rebuild
