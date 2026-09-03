{
  pkgs,
  user,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
  ];

  boot = {
    extraModprobeConfig = ''
      # The media workload benefits little from a very large ARC.
      options zfs zfs_arc_max=8589934592
    '';
    kernelPackages = pkgs.linuxPackages_latest;
    zfs.forceImportRoot = false;
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
    supportedFilesystems = [
      "btrfs"
      "zfs"
    ];
  };

  systemd.tmpfiles.rules = [
    "d /srv 2775 root users -"
  ];

  hardware = {
    enableRedistributableFirmware = true;
    graphics.enable = true;
  };

  networking = {
    # Stable ZFS host identifier derived from Opal's machine ID.
    hostId = "e1d2ff7e";
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
    zfs = {
      autoScrub = {
        enable = true;
        interval = "monthly";
        pools = ["storage"];
      };
      trim = {
        enable = true;
        interval = "weekly";
      };
    };
    udev.extraRules = ''
      # Authorize only the OWC Express 4M2, and only when the host IOMMU is
      # protecting Thunderbolt DMA.
      ACTION=="add", SUBSYSTEM=="thunderbolt", ATTR{unique_id}=="d4030000-0070-6718-2351-393f86545801", ATTRS{iommu_dma_protection}=="1", ATTR{authorized}=="0", ATTR{authorized}="1"
    '';
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
