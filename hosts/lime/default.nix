{
  config,
  pkgs,
  user,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ./storage.nix
  ];

  boot = {
    loader.systemd-boot = {
      enable = true;
      configurationLimit = 5;
    };
    loader.efi.canTouchEfiVariables = true;
    supportedFilesystems = ["btrfs"];
  };

  networking = {
    networkmanager.enable = true;
    firewall = {
      enable = true;
      trustedInterfaces = ["tailscale0"];
    };
  };

  time.timeZone = "Europe/Vienna";

  virtualisation.docker.enable = true;
  virtualisation.incus.enable = true;
  networking.nftables.enable = true;

  services = {
    fwupd.enable = true;
    openssh.openFirewall = false;
    fstrim.enable = true;
    tailscale.useRoutingFeatures = "client";

    smartd = {
      enable = true;
      autodetect = false;
      devices = [
        {
          device = "/dev/disk/by-id/nvme-eui.5cd2e4289141476a";
          options = "-d nvme";
        }
        {
          device = "/dev/disk/by-id/ata-ST4000VN008-2DR166_ZM40TMXE";
          options = "-d sat -n standby,q";
        }
        {
          device = "/dev/disk/by-id/ata-ST4000VN008-2DR166_ZM40TNB7";
          options = "-d sat -n standby,q";
        }
        {
          device = "/dev/disk/by-id/ata-ST4000VN008-2DR166_ZM40TPHV";
          options = "-d sat -n standby,q";
        }
      ];
    };

    btrfs.autoScrub = {
      enable = true;
      fileSystems = ["/"];
      interval = "monthly";
    };

    prometheus.exporters.node = {
      enable = true;
      port = 9100;
    };

    logind.settings.Login = {
      HandleLidSwitch = "ignore";
      HandleLidSwitchDocked = "ignore";
      HandleLidSwitchExternalPower = "ignore";
    };

    ntfy-maintenance-alerts = {
      enable = true;
      topicFile = config.sops.secrets.ntfy_maintenance_topic.path;
      systemdServices = [
        "btrfs-scrub--"
        "smartd"
      ];
      smartd.enable = true;
    };
  };

  users.users.${user.name}.extraGroups = ["networkmanager"];

  zramSwap.enable = true;

  environment.systemPackages = with pkgs; [
    btrfs-progs
    e2fsprogs
    ethtool
    fio
    lm_sensors
    pciutils
    restic
    smartmontools
    usbutils
  ];

  system.stateVersion = "26.05";
}
