{
  config,
  pkgs,
  inputs,
  ...
}: {
  environment.systemPackages = with pkgs;
    [
      asahi-bless
    ]
    ++ (import ./scripts.nix {inherit pkgs;});

  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;
  services.xserver = {
    enable = true;
    xkb.layout = "de";
    xkb.variant = "mac";
    autorun = true;
  };
}
