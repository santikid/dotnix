{
  config,
  user,
  ...
}: {
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

  services.peerHealthcheck = {
    enable = true;
    topicFile = config.sops.secrets.ntfy_maintenance_topic.path;
    targets = {
      obsidian = "http://obsidian:9100/";
      ruby = "http://ruby:9100/";
    };
  };
}
