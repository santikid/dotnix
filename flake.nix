{
  description = "my nix flake";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # manage user configuration with home-manager
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    darwin.url = "github:lnl7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";

    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";

    homebrew-cask.url = "github:homebrew/homebrew-cask";
    homebrew-cask.flake = false;

    homebrew-cask-versions.url = "github:homebrew/homebrew-cask-versions";
    homebrew-cask-versions.flake = false;
  };
  outputs = inputs @ {
    self,
    nixpkgs,
    home-manager,
    darwin,
    nix-homebrew,
    homebrew-cask,
    homebrew-cask-versions,
    ...
  }: let
    makeDarwin = system: extraModules: hostName: let
      pkgs = import nixpkgs {inherit system;};
    in
      darwin.lib.darwinSystem {
        system = system;
        specialArgs = {inherit pkgs inputs self darwin;};
        modules =
          [
            home-manager.darwinModules.default
            nix-homebrew.darwinModules.nix-homebrew
            {
              networking.hostName = hostName;
              home-manager.useUserPackages = true;
              home-manager.useGlobalPkgs = true;
              home-manager.extraSpecialArgs = {inherit inputs pkgs;};
            }
            {
              nix-homebrew = {
                enable = true;
                user = "santi";
                taps = {
                  "homebrew/homebrew-cask" = homebrew-cask;
                  "homebrew/homebrew-cask-versions" = homebrew-cask-versions;
                };
              };
            }
            ./common/darwin.nix
            ./common/home.nix
          ]
          ++ extraModules;
      };
    makeAsahi = system: extraModules: hostName: let
      pkgs = import nixpkgs {inherit system;};
    in
      nixpkgs.lib.nixosSystem {
        system = system;
        specialArgs = {inherit pkgs inputs self;};
        modules =
          [
            home-manager.nixosModules.default
            {
              networking.hostName = hostName;
              home-manager.useUserPackages = true;
              home-manager.useGlobalPkgs = true;
              home-manager.extraSpecialArgs = {inherit inputs pkgs;};
            }
            ./common/linux.nix
            ./common/home.nix
          ]
          ++ extraModules;
      };
  in {
    darwinConfigurations = {
      santibook = makeDarwin "aarch64-darwin" [] "santibook";
    };
    nixosConfigurations = {
      santisasahi = makeAsahi "aarch64-linux" [] "santisasahi";
    };
  };
}
