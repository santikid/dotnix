.PHONY: all bootstrap check format rebuild rekey regenerate-keys sync update upgrade

HOSTNAME := $(shell hostname)
NIX_REBUILD_FLAGS :=
ATTIC_URL := http://obsidian:8180/dotnix
ATTIC_PUBLIC_KEY := dotnix:l60JA9kCmi7QH4e9UONJagnC7aqyJkJc++qsiKCYU6M=
ATTIC_BOOTSTRAP_FLAGS := \
	--option extra-substituters $(ATTIC_URL) \
	--option extra-trusted-public-keys $(ATTIC_PUBLIC_KEY)

ifeq ($(HOSTNAME),santisasahi)
	NIX_REBUILD_FLAGS += --impure
endif

# Detect system type (Linux or Darwin)
SYS_TYPE := $(shell uname -s)

all:
	@echo "no command supplied (bootstrap/check/format/rebuild/rekey/update/upgrade)"

rekey:
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
	nix eval .#nixosConfigurations.razer.config.system.build.toplevel.drvPath --raw
	nix eval .#nixosConfigurations.santisasahi.config.networking.hostName --raw

rebuild:
ifeq ($(SYS_TYPE),Linux)
	@echo "Rebuilding NixOS configuration..."
	sudo nixos-rebuild switch --flake .#$(HOSTNAME) $(NIX_REBUILD_FLAGS)
endif
ifeq ($(SYS_TYPE),Darwin)
	@echo "Rebuilding Darwin configuration..."
	sudo darwin-rebuild switch --flake .#$(HOSTNAME) $(NIX_REBUILD_FLAGS)
endif

sync:
	git pull

bootstrap: NIX_REBUILD_FLAGS += $(ATTIC_BOOTSTRAP_FLAGS)
bootstrap: rebuild

update:
	nix flake update

upgrade: sync rebuild
