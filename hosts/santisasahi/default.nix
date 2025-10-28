{
  config,
  pkgs,
  inputs,
  user,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    inputs.nixos-apple-silicon.nixosModules.apple-silicon-support
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = false;

  networking.wireless.iwd = {
    enable = true;
    settings.General.EnableNetworkConfiguration = true;
  };
  networking.networkmanager = {
    enable = true;
    wifi.backend = "iwd";
  };
  hardware.asahi = {
    enable = true;
    setupAsahiSound = true;
  };
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings.General.Enable = "Source,Sink,Media,Socket";
  };
  services.blueman.enable = true;
  boot.kernelParams = [
    "apple_dcp.show_notch=1"
  ];
  system.stateVersion = "24.05";
}
