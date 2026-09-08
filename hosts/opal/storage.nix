{pkgs, ...}: let
  poolGuid = "4193332052382858745";
  owc4m2UdevRule = ''
    # Authorize only the OWC Express 4M2, and only when the host IOMMU is
    # protecting Thunderbolt DMA.
    ACTION=="add", SUBSYSTEM=="thunderbolt", ATTR{unique_id}=="d4030000-0070-6718-2351-393f86545801", ATTRS{iommu_dma_protection}=="1", ATTR{authorized}=="0", ATTR{authorized}="1"
  '';
  storageUdevRule = ''
    # Import this pool after all of its members appear, including after hot-plug.
    ACTION=="add", SUBSYSTEM=="block", ENV{ID_FS_TYPE}=="zfs_member", ENV{ID_FS_UUID}=="${poolGuid}", TAG+="systemd", ENV{SYSTEMD_WANTS}+="storage-pool.service"
  '';
in {
  boot = {
    extraModprobeConfig = ''
      # The media workload benefits little from a very large ARC.
      options zfs zfs_arc_max=8589934592
    '';
    supportedFilesystems = [
      "btrfs"
      "zfs"
    ];
    zfs.forceImportRoot = false;
  };

  # Stable ZFS host identifier derived from Opal's machine ID.
  networking.hostId = "e1d2ff7e";

  systemd.services.storage-pool = {
    description = "Import, unlock, and mount the 4M2 storage pool";
    path = [
      pkgs.coreutils
      pkgs.zfs
    ];
    script = ''
      # NixOS service scripts stop on error; keep ZFS's own diagnostic output.
      if ! zpool list -H -o name storage >/dev/null 2>&1; then
        timeout --kill-after=5s 15s zpool import -N -d /dev/disk/by-id \
          -o cachefile=none ${poolGuid}
      fi

      key_status=$(zfs get -H -o value keystatus storage)
      if [[ "$key_status" == "unavailable" ]]; then
        # Uses the dataset's existing keylocation; no secret is embedded in Nix.
        zfs load-key storage
      fi

      zfs mount -a
    '';
    unitConfig.ConditionPathExists = [
      "/dev/disk/by-id/nvme-CT4000P3SSD8_2324E6E26D33-part1"
      "/dev/disk/by-id/nvme-CT4000P3SSD8_2328E6ECAFF7-part1"
      "/dev/disk/by-id/nvme-CT4000P3SSD8_2328E6ECB013-part1"
      "/dev/disk/by-id/nvme-CT4000P3SSD8_2328E6ECB021-part1"
    ];
    # Stay inactive after import so subsequent device arrivals can retry it.
    # Consumers add Wants/After dependencies, not OnSuccess restart triggers.
    serviceConfig = {
      Type = "oneshot";
      TimeoutStartSec = "30s";
    };
  };

  services = {
    btrfs.autoScrub = {
      enable = true;
      fileSystems = ["/"];
      interval = "monthly";
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

  environment.systemPackages = with pkgs; [
    btrfs-progs
    fio
    nvme-cli
    smartmontools
  ];
}
