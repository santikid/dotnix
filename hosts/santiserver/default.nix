{user, ...}: {
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

  networking.knownNetworkServices = ["Wi-Fi" "Ethernet"];
}
