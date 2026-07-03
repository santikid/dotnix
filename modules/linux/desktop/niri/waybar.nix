{
  niri,
  theme,
  user,
}: {
  home-manager.users.${user.name}.programs.waybar = {
    enable = true;
    settings.mainBar = {
      layer = "top";
      position = "top";
      height = 40;
      spacing = 7;
      "modules-left" = niri.waybarModules.left;
      "modules-center" = niri.waybarModules.center;
      "modules-right" = niri.waybarModules.right;

      "niri/workspaces" = {
        format = "{icon}";
        "format-icons" = theme.icons.workspace;
      };
      "custom/overview" = {
        format = theme.icons.overview;
        tooltip = false;
        "on-click" = "${niri.commands.niri} msg action toggle-overview";
      };
      tray = {
        spacing = 10;
      };
      "custom/clipboard" = {
        format = theme.icons.clipboard;
        tooltip = true;
        "tooltip-format" = "Clipboard history";
        "on-click" = niri.commands.clipboardMenu;
      };
      idle_inhibitor = {
        format = "{icon}";
        "format-icons" = {
          activated = theme.icons.idleActive;
          deactivated = theme.icons.idleInactive;
        };
      };
      "custom/power-profile" = {
        exec = "${niri.commands.powerprofilesctl} get";
        format = "${theme.icons.power} {}";
        interval = 30;
        tooltip = true;
        "tooltip-format" = "Power profile";
        "on-click" = niri.commands.powerProfileMenu;
      };
      backlight = {
        format = "{icon} {percent}%";
        "format-icons" = theme.icons.brightness;
        "on-scroll-up" = "${niri.commands.brightnessctl} set +5%";
        "on-scroll-down" = "${niri.commands.brightnessctl} set 5%-";
      };
      pulseaudio = {
        format = "{icon} {volume}%";
        "format-muted" = theme.icons.volumeMuted;
        "format-icons".default = theme.icons.volume;
        "on-click" = niri.commands.pavucontrol;
        "on-click-right" = "${niri.commands.wpctl} set-mute @DEFAULT_AUDIO_SINK@ toggle";
        "on-scroll-up" = "${niri.commands.wpctl} set-volume @DEFAULT_AUDIO_SINK@ 0.05+ -l 1.0";
        "on-scroll-down" = "${niri.commands.wpctl} set-volume @DEFAULT_AUDIO_SINK@ 0.05-";
      };
      "custom/battery" = {
        exec = niri.commands.waybarBattery;
        interval = 30;
        "return-type" = "json";
        "on-click" = niri.commands.powerProfileMenu;
      };
      clock = {
        format = "{:%a %b %d  %H:%M}";
        "tooltip-format" = "{:%A, %B %d, %Y}";
      };
    };

    style = ''
            * {
              border: none;
              font-family: ${theme.fonts.ui}, "Symbols Nerd Font", "Symbols Nerd Font Mono", sans-serif;
              font-size: 12px;
              font-weight: 600;
              min-height: 0;
            }

            window#waybar {
              background: ${theme.colors.bar};
              border-bottom: 1px solid ${theme.colors.barBorder};
              color: ${theme.colors.text};
              padding: 0 12px;
            }

      ${niri.cssSelector niri.waybarStyledSelectors} {
              margin: 6px 0;
              padding: 0 12px;
              border-radius: 8px;
              background: ${theme.colors.surface};
            }

            #custom-overview:hover,
            #custom-clipboard:hover,
            #custom-power-profile:hover,
            #idle_inhibitor:hover,
            #backlight:hover,
            #workspaces button:hover {
              background: ${theme.colors.surfaceHover};
            }

            #custom-overview,
            #custom-clipboard,
            #idle_inhibitor {
              min-width: 24px;
              padding-left: 8px;
              padding-right: 8px;
            }

            #workspaces button {
              min-width: 24px;
              margin: 0 1px;
              padding: 0 6px;
              border-radius: 7px;
              color: ${theme.colors.muted};
            }

            #workspaces button.active {
              background: ${theme.colors.selected};
              color: ${theme.colors.selectedText};
            }

            #idle_inhibitor,
            #tray {
              color: ${theme.colors.muted};
            }

            #idle_inhibitor.activated,
            #custom-power-profile {
              color: ${theme.colors.accent};
            }

            #clock {
              min-width: 112px;
            }

            #pulseaudio.muted,
            #custom-battery.warning {
              color: ${theme.colors.warning};
            }

            #custom-battery.critical {
              color: ${theme.colors.critical};
            }
    '';
  };
}
