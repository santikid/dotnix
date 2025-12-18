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

  virtualisation.incus.enable = true;
  networking.nftables.enable = true;

  users.users.${user.name}.extraGroups = ["docker" "incus-admin"];

  networking.firewall = {
    enable = true;
    trustedInterfaces = [ "tailscale0" "incusbr0" ];
    allowedTCPPorts = [ 25565 25566 25567 ];
  };

  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  system.stateVersion = "24.05";
}
