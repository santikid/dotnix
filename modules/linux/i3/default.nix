{
  config,
  pkgs,
  user,
  ...
}: {
  environment.systemPackages = with pkgs; [
    i3
    feh
    rofi
    kdePackages.dolphin
    firefox
    ghostty
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
        feh
      ];
    };
  };

  home-manager.users.${user.name} = {
    xsession.windowManager.i3 = {
      enable = true;
      config = let
        modifier = "Mod1"; # Alt/Option key
        terminal = "ghostty";
        menu = "dmenu_run";
        browser = "firefox";
        files = "dolphin";
      in {
        inherit modifier;
        window = {
          border = 1;
          titlebar = false;
        };
        keybindings = pkgs.lib.mkOptionDefault ({
            "${modifier}+t" = "exec ${terminal}";
            "${modifier}+c" = "exec ${browser}";
            "${modifier}+q" = "kill";
            "${modifier}+f" = "exec ${files}";
            "${modifier}+d" = "exec ${menu}";
            "${modifier}+r" = "mode \"resize\"";

            # Focus movement
            "${modifier}+h" = "focus left";
            "${modifier}+j" = "focus down";
            "${modifier}+k" = "focus up";
            "${modifier}+l" = "focus right";

            # Window movement
            "${modifier}+Shift+h" = "move left";
            "${modifier}+Shift+j" = "move down";
            "${modifier}+Shift+k" = "move up";
            "${modifier}+Shift+l" = "move right";

            "${modifier}+Shift+r" = "reload; restart";

            # Workspace management
            "${modifier}+Tab" = "workspace back_and_forth";
          }
          // (builtins.listToAttrs (map (n: {
              name = "${modifier}+${toString n}";
              value = "workspace number ${toString n}";
            }) (pkgs.lib.range 1 10))
            // builtins.listToAttrs (map (n: {
              name = "${modifier}+Shift+${toString n}";
              value = "move container to workspace number ${toString n}";
            }) (pkgs.lib.range 1 10))));

        modes.resize = {
          h = "resize shrink width 10 px or 10 ppt";
          j = "resize grow height 10 px or 10 ppt";
          k = "resize shrink height 10 px or 10 ppt";
          l = "resize grow width 10 px or 10 ppt";

          Escape = "mode default";
          Return = "mode default";
        };

        gaps = {
          inner = 5;
          outer = 5;
          smartGaps = true;
          smartBorders = "on";
        };

        startup = [
          {
            command = "feh --bg-color black";
            always = true;
            notification = false;
          }
          {
            command = "xrandr --output eDP-1 --scale 2x2";
            always = true;
            notification = false;
          }
        ];
      };
    };

    home.file.".Xresources".text = ''
      Xft.dpi: 192
      Xft.autohint: 0
      Xft.lcdfilter: lcddefault
      Xft.hintstyle: hintslight
      Xft.rgba: rgb
      Xft.antialias: 1
    '';
  };
}
