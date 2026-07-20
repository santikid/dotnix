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
      height = 42;
      spacing = 0;
      "modules-left" = niri.waybarModules.left;
      "modules-center" = niri.waybarModules.center;
      "modules-right" = niri.waybarModules.right;

      "group/status" = {
        orientation = "horizontal";
        modules = [
          "tray"
          "custom/clipboard"
          "idle_inhibitor"
        ];
      };
      "group/controls" = {
        orientation = "horizontal";
        modules = [
          "custom/power-profile"
          "backlight"
          "pulseaudio"
          "custom/battery"
        ];
      };
      "group/clock" = {
        orientation = "horizontal";
        modules = ["clock#date" "clock#time"];
      };

      "niri/workspaces" = {
        format = "{index}";
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
        exec = niri.commands.waybarPowerProfile;
        format = "{text}";
        interval = 30;
        "return-type" = "json";
        tooltip = true;
        "on-click" = niri.commands.powerProfileMenu;
      };
      backlight = {
        format = "{icon}  {percent}%";
        "format-icons" = theme.icons.brightness;
        "on-scroll-up" = "${niri.commands.brightnessctl} set +5%";
        "on-scroll-down" = "${niri.commands.brightnessctl} set 5%-";
      };
      pulseaudio = {
        format = "{icon}  {volume}%";
        "format-muted" = theme.icons.volumeMuted;
        "format-icons".default = theme.icons.volume;
        "tooltip-format" = "{desc} · {volume}%\nClick: audio controls · Right click: advanced mixer";
        "on-click" = niri.commands.audioMenu;
        "on-click-middle" = niri.commands.pavucontrol;
        "on-click-right" = niri.commands.pavucontrol;
        "on-scroll-up" = "${niri.commands.wpctl} set-volume @DEFAULT_AUDIO_SINK@ 0.05+ -l 1.0";
        "on-scroll-down" = "${niri.commands.wpctl} set-volume @DEFAULT_AUDIO_SINK@ 0.05-";
      };
      "custom/battery" = {
        exec = niri.commands.waybarBattery;
        interval = 30;
        "return-type" = "json";
        "on-click" = niri.commands.powerProfileMenu;
      };
      "clock#date" = {
        format = "{:%a, %d %b}";
        "tooltip-format" = "{:%A, %B %d, %Y}";
      };
      "clock#time" = {
        format = "{:%H:%M}";
        "tooltip-format" = "{:%A, %B %d, %Y}";
      };
    };

    style = ''
      * {
        border: none;
        border-radius: 0;
        box-shadow: none;
        text-shadow: none;
        font-family: ${theme.fonts.ui}, "Symbols Nerd Font", "Symbols Nerd Font Mono", sans-serif;
        font-size: 12px;
        font-weight: 600;
        min-height: 0;
      }

      window#waybar {
        background: ${theme.colors.bar};
        border-bottom: 1px solid ${theme.colors.barBorder};
        color: ${theme.colors.text};
      }

      tooltip {
        background: ${theme.colors.bar};
        border: 1px solid ${theme.colors.barBorder};
        border-radius: 9px;
      }

      tooltip label {
        color: ${theme.colors.text};
        padding: 2px 4px;
      }

      #group-status,
      #group-controls,
      #group-clock {
        background: transparent;
      }

      #group-controls,
      #group-clock {
        margin-left: 6px;
        border-left: 1px solid ${theme.colors.barBorder};
      }

      #custom-clipboard,
      #idle_inhibitor,
      #custom-power-profile,
      #backlight,
      #pulseaudio,
      #custom-battery,
      #clock.date,
      #clock.time {
        min-height: 42px;
      }

      #workspaces {
        margin-left: 32px;
        padding: 0;
      }

      #workspaces button {
        min-width: 17px;
        margin: 0;
        padding: 0 8px;
        border-bottom: 2px solid transparent;
        background: transparent;
        color: ${theme.colors.dim};
        font-weight: 600;
        transition: background-color 120ms ease, color 120ms ease;
      }

      #workspaces button.active {
        border-bottom-color: ${theme.colors.accent};
        color: ${theme.colors.text};
        font-weight: 700;
      }

      #workspaces button.urgent {
        border-bottom-color: ${theme.colors.critical};
        color: ${theme.colors.critical};
      }

      #custom-clipboard:hover,
      #custom-power-profile:hover,
      #idle_inhibitor:hover,
      #backlight:hover,
      #pulseaudio:hover,
      #custom-battery:hover,
      #workspaces button:hover {
        background: ${theme.colors.surfaceHover};
      }

      #custom-clipboard,
      #idle_inhibitor,
      #custom-power-profile {
        min-width: 18px;
        padding: 0 10px;
      }

      #idle_inhibitor,
      #tray {
        color: ${theme.colors.muted};
      }

      #tray {
        padding: 0 10px;
      }

      #backlight,
      #pulseaudio,
      #custom-battery {
        padding: 0 10px;
      }

      #idle_inhibitor.activated,
      #custom-power-profile.power-saver,
      #custom-battery.charging,
      #custom-battery.plugged {
        color: ${theme.colors.accent};
      }

      #custom-power-profile.balanced {
        color: ${theme.colors.muted};
      }

      #custom-power-profile.performance,
      #pulseaudio.muted,
      #custom-battery.warning {
        color: ${theme.colors.warning};
      }

      #custom-battery.critical {
        color: ${theme.colors.critical};
      }

      #clock.date {
        padding: 0 5px 0 12px;
        color: ${theme.colors.muted};
        font-weight: 500;
      }

      #clock.time {
        min-width: 34px;
        margin-right: 32px;
        padding: 0 0 0 8px;
        color: ${theme.colors.text};
        font-weight: 700;
      }
    '';
  };
}
