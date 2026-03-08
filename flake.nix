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

    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs = inputs @ {
    self,
    nixpkgs,
    home-manager,
    darwin,
    nix-homebrew,
    homebrew-cask,
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
        hostName = "santibook";
        system = "aarch64-darwin";
        extraModules = [./modules/darwin/desktop ./packages/modules/devxtra.nix];
      };
      santiserver = {
        hostName = "santiserver";
        system = "aarch64-darwin";
        extraModules = [./modules/all/secrets ./hosts/santiserver ./modules/darwin/server];
      };
    };

    nixosHosts = {
      santi-gg = {
        hostName = "santi-gg";
        system = "x86_64-linux";
        extraModules = [./modules/all/secrets ./hosts/santi-gg ./modules/linux/server];
      };
    };

    commonModules = hostName: [
      ./modules/all
      ./modules/home
      ./packages
      {
        networking.hostName = hostName;
        home-manager.useUserPackages = true;
        home-manager.useGlobalPkgs = true;
        home-manager.extraSpecialArgs = {inherit inputs user;};
      }
    ];

    makeDarwin = hostName: system: extraModules:
      darwin.lib.darwinSystem {
        inherit system;
        specialArgs = {inherit inputs self user;};
        modules =
          [
            home-manager.darwinModules.default
            sops-nix.darwinModules.sops
            nix-homebrew.darwinModules.nix-homebrew
            ./modules/darwin
            {
              networking.computerName = hostName;
              networking.localHostName = hostName;
              nix-homebrew = {
                enable = true;
                user = user.name;
                autoMigrate = true;
                taps = {
                  "homebrew/homebrew-cask" = homebrew-cask;
                };
              };
            }
          ]
          ++ commonModules hostName
          ++ extraModules;
      };

    makeNixOS = hostName: system: extraModules:
      nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {inherit inputs self user;};
        modules =
          [
            home-manager.nixosModules.default
            sops-nix.nixosModules.sops
            ./modules/linux
            ./packages/linux.nix
          ]
          ++ commonModules hostName
          ++ extraModules;
      };
  in {
    darwinConfigurations =
      builtins.mapAttrs (
        name: host:
          makeDarwin host.hostName host.system host.extraModules
      )
      darwinHosts;

    nixosConfigurations =
      builtins.mapAttrs (
        name: host:
          makeNixOS host.hostName host.system host.extraModules
      )
      nixosHosts;
  };
}
