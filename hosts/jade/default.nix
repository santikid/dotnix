{
  config,
  user,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
  ];

  sops.age = {
    generateKey = false;
    sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
  };

  boot.loader.grub = {
    enable = true;
    device = "/dev/vda";
    configurationLimit = 5;
  };

  networking = {
    useDHCP = true;
    firewall = {
      enable = true;
      trustedInterfaces = ["tailscale0"];
      allowedTCPPorts = [22 80 443];
    };
  };

  virtualisation.docker.enable = true;
  users.users.${user.name}.extraGroups = ["docker"];

  services = {
    fstrim.enable = true;
    openssh.openFirewall = false;
    tailscale.openFirewall = true;

    prometheus.exporters.node = {
      enable = true;
      port = 9100;
    };

    peerHealthcheck = {
      enable = true;
      topicFile = config.sops.secrets.ntfy_maintenance_topic.path;
      targets.opal = "http://opal:9100/";
    };
  };

  systemd.tmpfiles.rules = [
    "d /srv 2775 root users -"
  ];

  zramSwap.enable = true;

  system.stateVersion = "26.05";
}
