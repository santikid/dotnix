{ inputs, ... }: {
  imports = [
    ./hardware-configuration.nix
  ];
  networking.wireless.iwd = {
    enable = true;
    settings.General.EnableNetworkConfiguration = true;
  };
}
