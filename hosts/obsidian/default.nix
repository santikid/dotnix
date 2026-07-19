{
  config,
  user,
  pkgs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ./secrets.nix
  ];

  networking.useDHCP = true;

  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 5;
  boot.loader.efi.canTouchEfiVariables = true;

  systemd.services.disable-eno1-k1 = {
    description = "Apply Intel I219 stability workarounds";
    wantedBy = ["network-pre.target"];
    before = ["network-pre.target"];
    wants = ["sys-subsystem-net-devices-eno1.device"];
    after = ["sys-subsystem-net-devices-eno1.device"];
    path = [pkgs.ethtool];
    script = ''
      ethtool --set-priv-flags eno1 disable-k1 on
      ethtool -K eno1 tso off gso off
      ethtool --show-priv-flags eno1
      ethtool -k eno1
    '';
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    unitConfig.ConditionKernelVersion = ">= 7.1";
  };

  virtualisation.docker.enable = true;

  virtualisation.incus.enable = true;

  networking.nftables.enable = true;
  systemd.services.docker.path = [pkgs.nftables];
  virtualisation.docker.daemon.settings = {
    "firewall-backend" = "nftables";
    "live-restore" = false;
  };

  users.users.${user.name}.extraGroups = ["docker" "incus-admin"];

  services.cloudflared = {
    enable = true;
    tunnels = {
      "0fe3d5d3-b10e-41d0-9b95-6520a5ca3ea4" = {
        credentialsFile = "${config.sops.secrets.cf_tunnel_obsidian.path}";
        default = "http_status:404";
      };
    };
  };

  services.atticd = {
    enable = true;
    environmentFile = config.sops.templates."atticd.env".path;
    settings = {
      listen = "[::]:8180";
      "api-endpoint" = "http://obsidian:8180/";
      "allowed-hosts" = [
        "obsidian:8180"
        "localhost:8180"
        "127.0.0.1:8180"
      ];
      storage = {
        type = "s3";
        region = "eu-central-003";
        bucket = "dotnix-cache";
        endpoint = "https://s3.eu-central-003.backblazeb2.com";
      };
      chunking = {
        "nar-size-threshold" = 0;
        "min-size" = 65536;
        "avg-size" = 131072;
        "max-size" = 262144;
      };
      "garbage-collection" = {
        interval = "12 hours";
        "default-retention-period" = "90 days";
      };
    };
  };

  services.cron = {
    enable = true;
    systemCronJobs = [
      "0 * * * *  root  /srv/backup.sh >> /tmp/srvbck.log"
    ];
  };

  networking.firewall = {
    enable = true;
    trustedInterfaces = ["tailscale0" "incusbr0"];
    allowedTCPPorts = [80 443];
  };

  services.smartd = {
    enable = true;
    autodetect = true;
  };

  services.btrfs.autoScrub = {
    enable = true;
    fileSystems = ["/"];
    interval = "monthly";
  };

  system.stateVersion = "24.05";
}
