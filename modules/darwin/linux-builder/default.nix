{
  config,
  pkgs,
  ...
}: let
  system = "aarch64-darwin";
  pkgs-darwin = import (builtins.fetchTarball {
    # nixpkgs-24.05-darwin
    url = "https://github.com/nixos/nixpkgs/archive/bf32c404263862fdbeb6e5f87a4bcbc6a01af565.tar.gz";
    sha256 = "132bd16a1wp145wz4m16w2maz0md6y2hp0qn5x1102wkyr9gkk0n";
  }) {inherit system;};
in {
  nix.linux-builder = {
    enable = true;
    config = {
      nix.settings.sandbox = false;
      virtualisation.rosetta.enable = true;
      boot.binfmt.emulatedSystems = ["x86_64-linux"];
    };
    ephemeral = true;
    package = pkgs-darwin.darwin.linux-builder;
    maxJobs = 4;
    supportedFeatures = ["kvm" "benchmark" "big-parallel" "nixos-test"];
    systems = ["x86_64-linux" "aarch64-linux"];
  };
  nix.settings.trusted-users = ["@admin"];
  launchd.daemons.linux-builder = {
    serviceConfig = {
      StandardOutPath = "/var/log/darwin-builder.log";
      StandardErrorPath = "/var/log/darwin-builder.log";
    };
  };
}
