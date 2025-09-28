{
  config,
  pkgs,
  inputs,
  user,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
  ];

  networking.useDHCP = true;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  virtualisation.docker.enable = true;
  users.users.${user.name}.extraGroups = ["docker"];

  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  system.stateVersion = "24.05";
}
