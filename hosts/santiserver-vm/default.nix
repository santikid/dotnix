{inputs, ...}: {
  imports = [
    ./hardware-configuration.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.useDHCP = true;

  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  networking.interfaces.enp0s1.ipv4.addresses = [
    {
      address = "192.168.1.3";
      prefixLength = 24;
    }
  ];

  system.stateVersion = "24.05";
}
