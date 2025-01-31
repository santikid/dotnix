{ inputs, ... }: {
  imports = [
    ./hardware-configuration.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  services.xserver = {
    enable = true;
    xkb.layout = "de";
    xkb.variant = "mac";
    autorun = true;
  };

  networking.useDHCP = true;
  networking.hostName = "santisvm";

  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  system.stateVersion = "24.05";
}
