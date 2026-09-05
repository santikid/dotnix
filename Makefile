.PHONY: all bootstrap check format rebuild rekey regenerate-keys sync update upgrade

HOSTNAME := $(shell hostname)
NIX_REBUILD_FLAGS :=
NIX_REBUILD_ENV :=
ATTIC_URL := http://opal:8180/dotnix
ATTIC_PUBLIC_KEY := dotnix:N7VDgNbJ+yj6YV97+97s5HrxQ38+27OSPm17BexG3qA=
# Replace stale cache URLs/keys during bootstrap, and pass configuration through
# sudo to every Nix subprocess instead of relying on --option extra-* flags.
ATTIC_BOOTSTRAP_ENV = env NIX_CONFIG="$$(printf '%s\n' "$$NIX_CONFIG" \
	'substituters = https://cache.nixos.org/ $(ATTIC_URL)' \
	'trusted-public-keys = cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY= $(ATTIC_PUBLIC_KEY)')"

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
	nix eval .#nixosConfigurations.opal.config.system.build.toplevel.drvPath --raw
	nix eval .#nixosConfigurations.lime.config.system.build.toplevel.drvPath --raw
	nix eval .#nixosConfigurations.jade.config.system.build.toplevel.drvPath --raw
	nix eval .#nixosConfigurations.ruby.config.system.build.toplevel.drvPath --raw
	nix eval .#nixosConfigurations.santisasahi.config.networking.hostName --raw

rebuild:
ifeq ($(SYS_TYPE),Linux)
	@echo "Rebuilding NixOS configuration..."
	sudo $(NIX_REBUILD_ENV) nixos-rebuild switch --flake .#$(HOSTNAME) $(NIX_REBUILD_FLAGS)
endif
ifeq ($(SYS_TYPE),Darwin)
	@echo "Rebuilding Darwin configuration..."
	sudo $(NIX_REBUILD_ENV) darwin-rebuild switch --flake .#$(HOSTNAME) $(NIX_REBUILD_FLAGS)
endif

sync:
	git pull

bootstrap: NIX_REBUILD_ENV = $(ATTIC_BOOTSTRAP_ENV)
bootstrap: rebuild

update:
	nix flake update

upgrade: sync rebuild
