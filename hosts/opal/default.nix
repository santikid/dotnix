{
  pkgs,
  user,
  ...
}: {
  imports = [
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
    prometheus.exporters.node = {
      enable = true;
      port = 9100;
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
