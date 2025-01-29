{ inputs, ... }: {
  imports = [
    ./hardware-configuration.nix
  ];

  networking.useDHCP = true;
  networking.hostName = "vm-aarch64";

  users.users.santi = {
    isNormalUser = true;
    home = "/home/santi";
    description = "Lukas Santner";
    shell = pkgs.zsh;
    extraGroups = [ "wheel" ];
  };

  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  system.stateVersion = "24.05";
}