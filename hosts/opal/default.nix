{
  pkgs,
  user,
  ...
}: {
  imports = [
    ./backup.nix
    ./cache.nix
    ./hardware-configuration.nix
    ./storage.nix
    ./virtualisation.nix
  ];

  sops = {
    age = {
      generateKey = false;
      sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
    };
    defaultSopsFile = ../../secrets/opal.yaml;
  };

  boot = {
    kernelPackages = pkgs.linuxPackages_latest;
    loader = {
      efi.canTouchEfiVariables = false;
      grub = {
        enable = true;
        efiSupport = true;
        efiInstallAsRemovable = true;
        configurationLimit = 5;
        mirroredBoots = [
          {
            path = "/boot-a";
            devices = ["nodev"];
          }
          {
            path = "/boot-b";
            devices = ["nodev"];
          }
        ];
      };
    };
  };

  systemd.tmpfiles.rules = [
    "d /srv 2775 root users -"
  ];

  hardware = {
    enableRedistributableFirmware = true;
    graphics.enable = true;
  };

  networking = {
    networkmanager.enable = true;
    nftables.enable = true;
    firewall = {
      enable = true;
      # Prometheus reaches this host's exporter from its dedicated Docker bridge.
      interfaces."br-monitoring".allowedTCPPorts = [9100];
    };
  };

  users.users.${user.name}.extraGroups = ["networkmanager"];

  services = {
    fwupd.enable = true;
    peerHealthcheck.targets = {
      jade = "http://jade:9100/";
      lime = "http://lime:9100/";
      ruby = "http://ruby:9100/";
    };

    ntfy-maintenance-alerts = {
      enable = true;
      systemdServices = [
        "smartd"
        "storage-pool"
        "zfs-scrub"
        "zfs-zed"
        "zpool-trim"
      ];
      smartd.enable = true;
    };
  };

  environment.systemPackages = with pkgs; [
    ethtool
    lm_sensors
    pciutils
    usbutils
  ];

  system.stateVersion = "26.05";
}
