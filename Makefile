.PHONY: all check format rebuild rekey regenerate-keys update upgrade

HOSTNAME := $(shell hostname)
NIX_REBUILD_FLAGS :=

ifeq ($(HOSTNAME),santisasahi)
	NIX_REBUILD_FLAGS += --impure
endif

# Detect system type (Linux or Darwin)
SYS_TYPE := $(shell uname -s)

all:
	@echo "no command supplied (check/format/rebuild/rekey/update/upgrade)"

rekey:
	gpg --recv-keys 644EFF248A9CA2D269C30A7A6AA809E3B3CCCA64
	nix-shell -p sops --run "sops updatekeys secrets/*.yaml"

regenerate-keys: rekey

format:
	nix fmt
	nix develop --command stylua -g "*.lua" -- $(CURDIR)/configs/nvim

check:
	nix eval .#darwinConfigurations.santibook.system.drvPath --raw
	nix eval .#darwinConfigurations.lisbon.system.drvPath --raw
	nix eval .#nixosConfigurations.obsidian.config.system.build.toplevel.drvPath --raw
	nix eval .#nixosConfigurations.ruby.config.system.build.toplevel.drvPath --raw
	nix eval .#nixosConfigurations.santisasahi.config.networking.hostName --raw

rebuild:
ifeq ($(SYS_TYPE),Linux)
	@echo "Rebuilding NixOS configuration..."
	sudo nixos-rebuild switch --flake .#$(HOSTNAME) $(NIX_REBUILD_FLAGS)
endif
ifeq ($(SYS_TYPE),Darwin)
	@echo "Rebuilding Darwin configuration..."
	sudo darwin-rebuild switch --flake .#$(HOSTNAME)
endif

update:
	nix flake update

upgrade: update rebuild
