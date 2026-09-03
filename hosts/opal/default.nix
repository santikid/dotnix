{
  pkgs,
  user,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
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
    supportedFilesystems = ["btrfs"];
  };

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

  virtualisation.docker = {
    enable = true;
    autoPrune = {
      enable = true;
      dates = "weekly";
      flags = ["--filter=until=30d"];
    };
    daemon.settings = {
      "firewall-backend" = "nftables";
      "live-restore" = false;
    };
  };
  systemd.services.docker.path = [pkgs.nftables];

  users.users.${user.name}.extraGroups = [
    "docker"
    "networkmanager"
  ];

  services = {
    btrfs.autoScrub = {
      enable = true;
      fileSystems = ["/"];
      interval = "monthly";
    };
    fstrim.enable = true;
    fwupd.enable = true;
    prometheus.exporters.node = {
      enable = true;
      port = 9100;
    };
    smartd = {
      enable = true;
      autodetect = true;
    };
  };

  zramSwap.enable = true;

  environment.systemPackages = with pkgs; [
    btrfs-progs
    docker-compose
    ethtool
    fio
    lm_sensors
    nvme-cli
    pciutils
    smartmontools
    usbutils
  ];

  system.stateVersion = "26.05";
}
