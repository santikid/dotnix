{
  config,
  pkgs,
  ...
}: {
  environment.systemPackages = with pkgs; [
    i3
  ];

  services.displayManager.sddm.enable = true;

  services.xserver = {
    enable = true;
    xkb.layout = "de";
    xkb.variant = "mac";
    autorun = true;
    windowManager.i3 = {
      enable = true;
      extraPackages = with pkgs; [
        dmenu
        i3status
        i3lock
      ];
    };
  };
  home-manager.users.santi = {
    xsession.windowManager.i3 = {
      enable = true;
      config = let
        modifier = config.services.xserver.windowManager.i3.config.modifier;
      in {
        modifier = "Mod4";
        terminal = "ghostty";
        menu = "dmenu_run";
      };
    };
  };
}
