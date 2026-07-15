{
  config,
  user,
  pkgs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
  ];

  networking.useDHCP = true;

  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 5;
  boot.loader.efi.canTouchEfiVariables = true;

  systemd.services.disable-eno1-k1 = {
    description = "Disable Intel I219 K1 power saving";
    wantedBy = ["network-pre.target"];
    before = ["network-pre.target"];
    wants = ["sys-subsystem-net-devices-eno1.device"];
    after = ["sys-subsystem-net-devices-eno1.device"];
    path = [pkgs.ethtool];
    script = ''
      ethtool --set-priv-flags eno1 disable-k1 on
      ethtool --show-priv-flags eno1
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
        credentialsFile = "${config.sops.secrets.cf_tunnel_santi_gg.path}";
        default = "http_status:404";
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

  services.borgmatic.enable = true;

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
