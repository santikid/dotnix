{ inputs, ... }: {
  imports = [
    ./hardware-configuration.nix
  ];

  networking.useDHCP = true;
  networking.hostName = "vm-aarch64";

  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  system.stateVersion = "24.05";
}