{
  description = "my nix flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    llm-agents.url = "github:numtide/llm-agents.nix";

    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    darwin.url = "github:lnl7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";

    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";

    homebrew-cask.url = "github:homebrew/homebrew-cask";
    homebrew-cask.flake = false;

    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    niri.url = "github:sodiboo/niri-flake";
    niri.inputs.nixpkgs.follows = "nixpkgs";

    nixos-apple-silicon.url = "github:nix-community/nixos-apple-silicon/main";
    nixos-apple-silicon.inputs.nixpkgs.follows = "nixpkgs";

    zen-browser.url = "github:0xc000022070/zen-browser-flake";
    zen-browser.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs = inputs @ {
    self,
    nixpkgs,
    home-manager,
    darwin,
    nix-homebrew,
    homebrew-cask,
    sops-nix,
    niri,
    nixos-apple-silicon,
    zen-browser,
    ...
  }: let
    lib = nixpkgs.lib;

    systems = [
      "aarch64-darwin"
      "aarch64-linux"
      "x86_64-linux"
    ];

    forAllSystems = lib.genAttrs systems;

    user = {
      name = "santi";
      description = "Lukas Santner";
      email = "lukas@santi.gg";
      sshKeys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILds3nmPYniDOxaeLUY6B7Om/nQF04wXpIqWaHwrkriA santi"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF3RkGoQaJGtdljyefEXXPOjviIJeWVc+CHU/s9RMBLG personal"
      ];
    };

    darwinHosts = {
      santibook = {
        system = "aarch64-darwin";
        extraModules = [
          ./hosts/santibook
          ./modules/darwin/desktop.nix
          ./modules/coding-agents.nix
        ];
      };
      lisbon = {
        system = "aarch64-darwin";
        extraModules = [./hosts/lisbon ./modules/darwin/server.nix];
      };
    };

    nixosHosts = {
      obsidian = {
        system = "x86_64-linux";
        extraModules = [./modules/secrets.nix ./hosts/obsidian ./modules/linux/server.nix];
      };

      ruby = {
        system = "x86_64-linux";
        extraModules = [
          ./hosts/ruby
          ./modules/linux/server.nix
          ./modules/coding-agents.nix
        ];
      };

      santisasahi = {
        system = "aarch64-linux";
        extraModules = [
          nixos-apple-silicon.nixosModules.default
          ./hosts/santisasahi
          ./modules/linux/desktop/niri
          ./modules/coding-agents.nix
        ];
      };
    };

    commonModules = hostName: [
      ./modules/common/base.nix
      ./modules/home.nix
      ./modules/packages.nix
      ({...}: {
        networking.hostName = hostName;
        home-manager.useUserPackages = true;
        home-manager.useGlobalPkgs = true;
        home-manager.extraSpecialArgs = {inherit inputs user;};
      })
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
          ]
          ++ commonModules hostName
          ++ extraModules;
      };
  in {
    darwinConfigurations =
      builtins.mapAttrs (
        name: host:
          makeDarwin name host.system host.extraModules
      )
      darwinHosts;

    nixosConfigurations =
      builtins.mapAttrs (
        name: host:
          makeNixOS name host.system host.extraModules
      )
      nixosHosts;

    formatter = forAllSystems (system: let
      pkgs = import nixpkgs {inherit system;};
    in
      pkgs.alejandra);

    devShells = forAllSystems (system: let
      pkgs = import nixpkgs {inherit system;};
    in {
      default = pkgs.mkShell {
        packages = [
          pkgs.alejandra
          pkgs.deadnix
          pkgs.shellcheck
          pkgs.statix
          pkgs.stylua
        ];
      };
    });
  };
}
