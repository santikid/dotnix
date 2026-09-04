{user, ...}: {
  imports = [
    ./hardware-configuration.nix
  ];

  boot.loader.grub = {
    enable = true;
    device = "/dev/sda";
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
  };

  systemd.tmpfiles.rules = [
    "d /srv 2775 root users -"
  ];

  zramSwap.enable = true;

  system.stateVersion = "26.05";
}
