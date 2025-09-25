{
  config,
  pkgs,
  inputs,
  user,
  ...
}: {
  imports = [
    ../../polyfills/darwin/traefik.nix
    ./traefik.nix
  ];
  home-manager.users.${user.name} = {
    home.sessionPath = [
      "/opt/podman/bin"
    ];
  };

  homebrew.casks = ["jellyfin" "podman-desktop"];

  networking = {
    dns = ["1.1.1.1" "9.9.9.9"];
    knownNetworkServices = ["Wi-Fi" "Ethernet"];
  };
}
