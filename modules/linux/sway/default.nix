{
  config,
  pkgs,
  user,
  ...
}: {
  environment.systemPackages = with pkgs; [
    sway
    swaylock
    swayidle
    waybar
    wofi
    ghostty
    swaybg
    grim
    slurp
    dolphin
    firefox
  ];

  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
  };

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --cmd sway";
      };
    };
  };

  home-manager.users.${user.name} = {
    wayland.windowManager.sway = {
      enable = true;
      config = let
        modifier = "Mod4"; # Super key
        terminal = "ghostty";
        menu = "wofi --show drun";
        browser = "firefox";
        files = "dolphin";
      in {
        inherit modifier terminal menu;

        keybindings =
          {
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

            "${modifier}+Shift+r" = "reload";

            # Workspaces
            "${modifier}+Tab" = "workspace back_and_forth";
          }
          // (builtins.listToAttrs (map (n: {
              name = "${modifier}+${toString n}";
              value = "workspace number ${toString n}";
            }) (pkgs.lib.range 1 10))
            // builtins.listToAttrs (map (n: {
              name = "${modifier}+Shift+${toString n}";
              value = "move container to workspace number ${toString n}";
            }) (pkgs.lib.range 1 10)));

        modes.resize = {
          h = "resize shrink width 10px";
          j = "resize grow height 10px";
          k = "resize shrink height 10px";
          l = "resize grow width 10px";

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
          {command = "swaybg --color '#000000'";}
          {command = "swaymsg output * scale 2";}
        ];

        window = {
          border = 1;
          titlebar = false;
        };
      };

      extraConfig = ''
        input type:touchpad {
          tap enabled
          natural_scroll enabled
        }

        output * scale 2
      '';
    };

    home.file.".config/waybar/config".text = ''
      {
        "layer": "top",
        "position": "top",
        "height": 30,
        "modules-left": ["sway/workspaces"],
        "modules-center": ["sway/window"],
        "modules-right": ["network", "pulseaudio", "battery", "clock"],
        "sway/workspaces": {
          "format": "{name}"
        },
        "clock": {
          "format": "{:%H:%M}"
        }
      }
    '';
  };

  environment.sessionVariables = {
    MOZ_ENABLE_WAYLAND = "1";
    QT_QPA_PLATFORM = "wayland";
    XDG_CURRENT_DESKTOP = "sway";
  };

  security.polkit.enable = true;
  security.pam.services.swaylock = {};

  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = [pkgs.xdg-desktop-portal-gtk];
  };
}
