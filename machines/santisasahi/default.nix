{ inputs, ... }: {
  imports = [
    ./hardware-configuration.nix
     inputs.nixos-apple-silicon.nixosModules.apple-silicon-support
  ];
  networking.wireless.iwd = {
    enable = true;
    settings.General.EnableNetworkConfiguration = true;
  };
  networking.networkmanager.wifi.backend = "iwd";
  networking.networkmanager.enable = true;
  hardware.asahi.extractPeripheralFirmware = false;
              hardware.asahi.useExperimentalGPUDriver = true;

              nixpkgs.overlays = [
                inputs.nixos-apple-silicon.overlays.apple-silicon-overlay
              ]; 
}
