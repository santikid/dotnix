{user, ...}: {
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
      allowedTCPPorts = [22 80 443];
    };
  };

  virtualisation.docker.enable = true;
  users.users.${user.name}.extraGroups = ["docker"];

  services = {
    openssh.openFirewall = false;
    qemuGuest.enable = true;
    peerHealthcheck.targets.opal = "http://opal:9100/";
  };

  systemd.tmpfiles.rules = [
    "d /srv 2775 root users -"
  ];

  system.stateVersion = "26.05";
}
