{ inputs, ... }: {
  imports = [
    ./hardware-configuration.nix
     inputs.nixos-apple-silicon.nixosModules.apple-silicon-support
  ];
  networking.wireless.iwd = {
    enable = true;
    settings.General.EnableNetworkConfiguration = true;
  };
  networking.nameservers = [
    "1.1.1.1"
    "1.0.0.1"
  ];
  networking.networkmanager.wifi.backend = "iwd";
  networking.networkmanager.enable = true;

  hardware.asahi = {
    useExperimentalGPUDriver = true;
    peripheralFirmwareDirectory = /boot/asahi;
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

  nixpkgs.overlays = [
    inputs.nixos-apple-silicon.overlays.apple-silicon-overlay
  ]; 
}
