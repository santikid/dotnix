{
  config,
  lib,
  pkgs,
  user,
  ...
}: {
  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";

  boot.loader.systemd-boot = {
    enable = true;
    configurationLimit = 8;
  };
  boot.loader.efi.canTouchEfiVariables = false;
  boot.supportedFilesystems = ["btrfs"];

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "btrfs";
    options = ["subvol=root" "compress=zstd" "noatime"];
  };

  fileSystems."/nix" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "btrfs";
    options = ["subvol=nix" "compress=zstd" "noatime"];
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "btrfs";
    options = ["subvol=home" "compress=zstd" "noatime"];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/EFI";
    fsType = "vfat";
    options = ["fmask=0022" "dmask=0022"];
  };

  swapDevices = [];
  zramSwap.enable = true;
  services.fstrim.enable = true;

  networking.networkmanager = {
    enable = true;
    wifi.backend = "iwd";
  };

  hardware.asahi.extractPeripheralFirmware =
    lib.mkDefault (config.hardware.asahi.peripheralFirmwareDirectory != null);

  hardware.bluetooth.enable = true;
  services.blueman.enable = true;
  services.upower.enable = true;
  services.power-profiles-daemon.enable = true;

  nix.settings = {
    trusted-users = ["root" "@wheel" user.name];
    extra-substituters = [
      "https://nixos-apple-silicon.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nixos-apple-silicon.cachix.org-1:8psDu5SA5dAD7qA0zMy5UT292TxeEPzIz8VVEr2Js20="
    ];
  };

  environment.systemPackages = with pkgs; [
    brightnessctl
    libinput
    lm_sensors
    pciutils
    powertop
    usbutils
  ];

  system.stateVersion = "26.05";
}
