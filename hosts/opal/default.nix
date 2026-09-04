{
  config,
  pkgs,
  user,
  ...
}: {
  imports = [
    ./cache.nix
    ./hardware-configuration.nix
    ./storage.nix
    ./virtualisation.nix
  ];

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
      trustedInterfaces = ["tailscale0"];
    };
  };

  users.users.${user.name}.extraGroups = ["networkmanager"];

  services = {
    fwupd.enable = true;
    tailscale.openFirewall = true;

    prometheus.exporters.node = {
      enable = true;
      port = 9100;
    };

    peerHealthcheck = {
      enable = true;
      topicFile = config.sops.secrets.ntfy_maintenance_topic.path;
      targets = {
        jade = "http://jade:9100/";
        lime = "http://lime:9100/";
        ruby = "http://ruby:9100/";
      };
    };

    ntfy-maintenance-alerts = {
      enable = true;
      topicFile = config.sops.secrets.ntfy_maintenance_topic.path;
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

  zramSwap.enable = true;

  environment.systemPackages = with pkgs; [
    ethtool
    lm_sensors
    pciutils
    usbutils
  ];

  system.stateVersion = "26.05";
}
