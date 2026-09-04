{
  pkgs,
  user,
  ...
}: let
  owc4m2UdevRule = ''
    # Authorize only the OWC Express 4M2, and only when the host IOMMU is
    # protecting Thunderbolt DMA.
    ACTION=="add", SUBSYSTEM=="thunderbolt", ATTR{unique_id}=="d4030000-0070-6718-2351-393f86545801", ATTRS{iommu_dma_protection}=="1", ATTR{authorized}=="0", ATTR{authorized}="1"
  '';
  storageUdevRule = ''
    # Import this pool after all of its members appear, including after hot-plug.
    ACTION=="add", SUBSYSTEM=="block", ENV{ID_FS_TYPE}=="zfs_member", ENV{ID_FS_UUID}=="4193332052382858745", TAG+="systemd", ENV{SYSTEMD_WANTS}+="storage-pool.service"
  '';
in {
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
      trustedInterfaces = [
        "incusbr0"
        "tailscale0"
      ];
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
  virtualisation.incus.enable = true;

  systemd = {
    services = {
      docker.path = [pkgs.nftables];

      storage-pool = {
        description = "Import, unlock, and mount the 4M2 storage pool";
        path = [
          pkgs.coreutils
          pkgs.zfs
        ];
        script = ''
          if ! zpool list -H -o name storage >/dev/null 2>&1; then
            if ! timeout --kill-after=5s 15s zpool import -N -d /dev/disk/by-id -o cachefile=none 4193332052382858745; then
              echo "Could not import the storage pool; leaving storage offline."
              exit 0
            fi
          fi

          if ! key_status="$(zfs get -H -o value keystatus storage 2>/dev/null)"; then
            echo "Could not read the storage encryption state; leaving storage unmounted."
            exit 0
          fi

          if [[ "$key_status" == "unavailable" ]]; then
            if [[ ! -r /var/lib/zfs/keys/storage.key ]]; then
              echo "The storage encryption key is unavailable; leaving storage unmounted."
              exit 0
            fi
            if ! zfs load-key storage; then
              echo "Could not unlock the storage pool; leaving storage unmounted."
              exit 0
            fi
          fi

          if ! zfs mount -a; then
            echo "The storage pool is online, but one or more datasets could not be mounted."
            exit 0
          fi
        '';
        unitConfig.ConditionPathExists = [
          "/dev/disk/by-id/nvme-CT4000P3SSD8_2324E6E26D33-part1"
          "/dev/disk/by-id/nvme-CT4000P3SSD8_2328E6ECAFF7-part1"
          "/dev/disk/by-id/nvme-CT4000P3SSD8_2328E6ECB013-part1"
          "/dev/disk/by-id/nvme-CT4000P3SSD8_2328E6ECB021-part1"
        ];
        serviceConfig = {
          Type = "oneshot";
          TimeoutStartSec = "30s";
        };
      };
    };
  };

  users.users.${user.name}.extraGroups = [
    "docker"
    "incus-admin"
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
    udev.extraRules = owc4m2UdevRule + storageUdevRule;
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
