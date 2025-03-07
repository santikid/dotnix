{
  description = "my nix flake";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    darwin.url = "github:lnl7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";

    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";

    homebrew-cask.url = "github:homebrew/homebrew-cask";
    homebrew-cask.flake = false;

    homebrew-cask-versions.url = "github:homebrew/homebrew-cask-versions";
    homebrew-cask-versions.flake = false;

    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";

    sops-nix.url = "github:Mic92/sops-nix";
  };
  outputs = inputs @ {
    self,
    nixpkgs,
    home-manager,
    darwin,
    nix-homebrew,
    homebrew-cask,
    homebrew-cask-versions,
    sops-nix,
    ...
  }: let
    user = {
      name = "santi";
      description = "Lukas Santner";
      email = "lukas@santi.gg";
    };
    darwinHosts = {
      santibook = {
        inherit user;
        hostName = "santibook";
        system = "aarch64-darwin";
        extraModules = [./modules/darwin/aerospace ./modules/darwin/desktop ./modules/home/secrets];
      };
      santimac = {
        inherit user;
        hostName = "santimac";
        system = "aarch64-darwin";
        extraModules = [./modules/darwin/desktop];
      };
      santiserver = {
        inherit user;
        hostName = "santiserver";
        system = "aarch64-darwin";
        extraModules = [./modules/darwin/aerospace ./modules/darwin/server];
      };
    };
    nixosHosts = {
      devbox = {
        inherit user;
        hostName = "devbox";
        system = "x86_64-linux";
        extraModules = [./hosts/devbox ./modules/linux/ssh-server];
      };
      paranix = {
        inherit user;
        hostName = "paranix";
        system = "aarch64-linux";
        extraModules = [./hosts/paranix ./modules/linux/i3 ./modules/linux/ssh-server];
      };
    };

    makeSystem = hostName: user: isDarwin: system: extraModules: let
      pkgs = import nixpkgs {inherit system;};
      makeFn =
        if isDarwin
        then darwin.lib.darwinSystem
        else nixpkgs.lib.nixosSystem;
      homeManager =
        if isDarwin
        then home-manager.darwinModules.default
        else home-manager.nixosModules.default;
      sopsNix =
        if isDarwin
        then sops-nix.darwinModules.sops
        else sops-nix.nixosModules.sops;
    in
      makeFn {
        inherit system;
        specialArgs = {inherit inputs self user;};
        modules =
          [
            homeManager
            sopsNix
            ./modules/all
            ./modules/home
            {
              networking.hostName = hostName;
              home-manager.useUserPackages = true;
              home-manager.useGlobalPkgs = true;
              home-manager.extraSpecialArgs = {inherit inputs pkgs user;};
            }
            (
              if isDarwin
              then ./modules/darwin
              else ./modules/linux
            )
            (
              if isDarwin
              then nix-homebrew.darwinModules.nix-homebrew
              else {}
            )
            (
              if isDarwin
              then {
                nix-homebrew = {
                  enable = true;
                  user = user.name;
                  taps = {
                    "homebrew/homebrew-cask" = homebrew-cask;
                    "homebrew/homebrew-cask-versions" = homebrew-cask-versions;
                  };
                };
              }
              else {}
            )
          ]
          ++ extraModules;
      };
  in {
    # Generate darwinConfigurations from darwinHosts
    darwinConfigurations =
      builtins.mapAttrs (
        name: host:
          makeSystem host.hostName host.user true host.system host.extraModules
      )
      darwinHosts;

    # Generate nixosConfigurations from nixosHosts
    nixosConfigurations =
      builtins.mapAttrs (
        name: host:
          makeSystem host.hostName host.user false host.system host.extraModules
      )
      nixosHosts;
  };
}
