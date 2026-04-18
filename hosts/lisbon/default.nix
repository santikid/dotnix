{user, ...}: {
  home-manager.users.${user.name} = {
    home.sessionPath = [
      "/opt/podman/bin"
    ];
  };

  homebrew.casks = ["jellyfin" "podman-desktop"];

  networking.knownNetworkServices = ["Wi-Fi" "Ethernet"];

  services.prometheus.exporters.node = {
    enable = true;
    port = 9100;
  };
}
