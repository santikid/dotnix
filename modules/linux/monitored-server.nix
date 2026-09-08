{config, ...}: {
  imports = [
    ./server.nix
    ../healthchecks.nix
    ./ntfy-maintenance-alerts.nix
    ../secrets/ntfy.nix
  ];

  networking.firewall.trustedInterfaces = ["tailscale0"];
  services.tailscale.openFirewall = true;
  services.fstrim.enable = true;
  zramSwap.enable = true;

  services.prometheus.exporters.node = {
    enable = true;
    port = 9100;
  };

  services.peerHealthcheck = {
    enable = true;
    topicFile = config.sops.secrets.ntfy_maintenance_topic.path;
  };
  services.ntfy-maintenance-alerts.topicFile = config.sops.secrets.ntfy_maintenance_topic.path;
}
