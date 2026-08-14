{
  pkgs,
  user,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
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

  services = {
    openssh.openFirewall = false;
    fstrim.enable = true;

    smartd = {
      enable = true;
      autodetect = true;
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
  };

  users.users.${user.name}.extraGroups = ["networkmanager"];

  zramSwap.enable = true;

  environment.systemPackages = with pkgs; [
    btrfs-progs
    e2fsprogs
    fio
    pciutils
    restic
    smartmontools
    usbutils
  ];

  system.stateVersion = "26.05";
}
