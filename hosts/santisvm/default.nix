{ inputs, ... }: {
  imports = [
    ./hardware-configuration.nix
  ];

  networking.useDHCP = true;
  networking.hostName = "santisvm";

  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  system.stateVersion = "24.05";
}