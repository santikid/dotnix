{
  config,
  pkgs,
  user,
  ...
}: {
  environment.systemPackages = with pkgs; [
    brightnessctl
    foot
    fuzzel
    grim
    imv
    kdePackages.dolphin
    mako
    networkmanagerapplet
    pavucontrol
    playerctl
    slurp
    swaybg
    swayidle
    swaylock
    waybar
    wl-clipboard
    xdg-utils
    xwayland-satellite
  ];

  programs.niri = {
    enable = true;
    useNautilus = false;
  };

  programs.firefox.enable = true;

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --remember-user-session --cmd ${config.programs.niri.package}/bin/niri-session";
      };
    };
  };

  security.pam.services.swaylock = {};
  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = pkgs.stdenv.hostPlatform.isx86;
    pulse.enable = true;
    wireplumber.enable = true;
  };

  environment.sessionVariables = {
    MOZ_ENABLE_WAYLAND = "1";
    NIXOS_OZONE_WL = "1";
    QT_QPA_PLATFORM = "wayland";
    QT_QPA_PLATFORMTHEME = "gtk3";
    TERMINAL = "foot";
    XDG_CURRENT_DESKTOP = "niri";
    XCURSOR_SIZE = "24";
    XCURSOR_THEME = "Bibata-Modern-Ice";
  };

  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
    extraPortals = [pkgs.xdg-desktop-portal-gtk];
  };

  home-manager.users.${user.name} = {
    home.file.".config/niri/config.kdl".text = ''
      input {
          keyboard {
              xkb {
                  layout "de"
                  variant "mac"
              }
          }

          touchpad {
              tap
              natural-scroll
          }
      }

      output "eDP-1" {
          scale 2
      }

      layout {
          gaps 8
          center-focused-column "never"

          preset-column-widths {
              proportion 0.33333
              proportion 0.5
              proportion 0.66667
          }

          default-column-width {
              proportion 0.5;
          }

          focus-ring {
              width 2
              active-color "#a9dc76"
              inactive-color "#444444"
          }

          border {
              off
          }
      }

      spawn-at-startup "mako"
      spawn-at-startup "nm-applet" "--indicator"
      spawn-at-startup "swaybg" "-c" "#0d1017"
      spawn-at-startup "swayidle" "-w" "timeout" "900" "swaylock -f -c 0d1017" "before-sleep" "swaylock -f -c 0d1017"
      spawn-at-startup "waybar"
      spawn-at-startup "xwayland-satellite"

      hotkey-overlay {
          skip-at-startup
      }

      prefer-no-csd
      screenshot-path "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png"

      binds {
          Mod+Shift+Slash { show-hotkey-overlay; }

          Mod+T { spawn "foot"; }
          Mod+D { spawn "fuzzel"; }
          Mod+C { spawn "firefox"; }
          Mod+F { spawn "dolphin"; }
          Super+Alt+L { spawn "swaylock" "-f" "-c" "101010"; }

          XF86AudioRaiseVolume allow-when-locked=true { spawn-sh "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1+ -l 1.0"; }
          XF86AudioLowerVolume allow-when-locked=true { spawn-sh "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1-"; }
          XF86AudioMute allow-when-locked=true { spawn-sh "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"; }
          XF86AudioMicMute allow-when-locked=true { spawn-sh "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"; }
          XF86MonBrightnessUp allow-when-locked=true { spawn "brightnessctl" "set" "+5%"; }
          XF86MonBrightnessDown allow-when-locked=true { spawn "brightnessctl" "set" "5%-"; }

          Mod+O repeat=false { toggle-overview; }
          Mod+Q repeat=false { close-window; }

          Mod+H { focus-column-left; }
          Mod+J { focus-window-down; }
          Mod+K { focus-window-up; }
          Mod+L { focus-column-right; }

          Mod+Ctrl+H { move-column-left; }
          Mod+Ctrl+J { move-window-down; }
          Mod+Ctrl+K { move-window-up; }
          Mod+Ctrl+L { move-column-right; }

          Mod+U { focus-workspace-down; }
          Mod+I { focus-workspace-up; }
          Mod+Ctrl+U { move-column-to-workspace-down; }
          Mod+Ctrl+I { move-column-to-workspace-up; }

          Mod+1 { focus-workspace 1; }
          Mod+2 { focus-workspace 2; }
          Mod+3 { focus-workspace 3; }
          Mod+4 { focus-workspace 4; }
          Mod+5 { focus-workspace 5; }
          Mod+6 { focus-workspace 6; }
          Mod+7 { focus-workspace 7; }
          Mod+8 { focus-workspace 8; }
          Mod+9 { focus-workspace 9; }

          Mod+Ctrl+1 { move-column-to-workspace 1; }
          Mod+Ctrl+2 { move-column-to-workspace 2; }
          Mod+Ctrl+3 { move-column-to-workspace 3; }
          Mod+Ctrl+4 { move-column-to-workspace 4; }
          Mod+Ctrl+5 { move-column-to-workspace 5; }
          Mod+Ctrl+6 { move-column-to-workspace 6; }
          Mod+Ctrl+7 { move-column-to-workspace 7; }
          Mod+Ctrl+8 { move-column-to-workspace 8; }
          Mod+Ctrl+9 { move-column-to-workspace 9; }

          Mod+BracketLeft { consume-or-expel-window-left; }
          Mod+BracketRight { consume-or-expel-window-right; }
          Mod+R { switch-preset-column-width; }
          Mod+Shift+R { switch-preset-column-width-back; }
          Mod+M { maximize-window-to-edges; }
          Mod+V { toggle-window-floating; }
          Mod+Shift+F { fullscreen-window; }
          Mod+Minus { set-column-width "-10%"; }
          Mod+Equal { set-column-width "+10%"; }

          Print { screenshot; }
          Ctrl+Print { screenshot-screen; }
          Alt+Print { screenshot-window; }

          Mod+Escape allow-inhibiting=false { toggle-keyboard-shortcuts-inhibit; }
          Mod+Shift+P { power-off-monitors; }
          Mod+Shift+E { quit; }
          Ctrl+Alt+Delete { quit; }
      }
    '';

    home.file.".config/waybar/config".text = ''
      {
        "layer": "top",
        "position": "top",
        "height": 42,
        "spacing": 8,
        "modules-left": ["niri/workspaces", "niri/window"],
        "modules-center": [],
        "modules-right": ["tray", "network", "bluetooth", "backlight", "pulseaudio", "battery", "clock"],
        "niri/workspaces": {
          "format": "{index}"
        },
        "tray": {
          "spacing": 10
        },
        "bluetooth": {
          "format": "bt {status}",
          "format-disabled": "bt off",
          "format-off": "bt off",
          "format-connected": "bt {num_connections}",
          "tooltip-format": "{controller_alias}",
          "tooltip-format-connected": "{controller_alias}: {device_alias}",
          "on-click": "blueman-manager"
        },
        "backlight": {
          "format": "sun {percent}%",
          "on-scroll-up": "brightnessctl set +5%",
          "on-scroll-down": "brightnessctl set 5%-"
        },
        "network": {
          "format-ethernet": "net {ifname}",
          "format-wifi": "wifi {essid}",
          "format-disconnected": "net offline",
          "tooltip-format-wifi": "{ifname}: {ipaddr}/{cidr} {signalStrength}%",
          "on-click": "nm-connection-editor",
          "on-click-right": "nm-applet"
        },
        "pulseaudio": {
          "format": "vol {volume}%",
          "format-muted": "vol muted",
          "on-click": "pavucontrol",
          "on-click-right": "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        },
        "battery": {
          "states": {
            "warning": 30,
            "critical": 15
          },
          "format": "bat {capacity}%",
          "format-charging": "bat {capacity}%+",
          "format-plugged": "bat {capacity}%="
        },
        "clock": {
          "format": "{:%H:%M}",
          "tooltip-format": "{:%A, %d %B %Y}"
        }
      }
    '';

    home.file.".config/waybar/style.css".text = ''
      * {
        border: none;
        font-family: Iosevka, monospace;
        font-size: 13px;
        min-height: 0;
      }

      window#waybar {
        background: rgba(13, 16, 23, 0.94);
        border-bottom: 1px solid rgba(156, 207, 216, 0.28);
        color: #e8eaed;
      }

      #workspaces,
      #window,
      #tray,
      #bluetooth,
      #backlight,
      #network,
      #pulseaudio,
      #battery,
      #clock {
        margin: 7px 0;
        padding: 0 12px;
        border-radius: 7px;
        background: rgba(24, 29, 39, 0.82);
      }

      #workspaces button {
        margin: 0 2px;
        padding: 0 9px;
        border-radius: 6px;
        color: #8b95a7;
      }

      #workspaces button.active {
        background: #9ccfd8;
        color: #0d1017;
      }

      #window {
        color: #c4c8d2;
      }

      #network.disconnected,
      #pulseaudio.muted,
      #battery.warning {
        color: #f6c177;
      }

      #battery.critical {
        color: #eb6f92;
      }
    '';

    home.file.".config/foot/foot.ini".text = ''
      font=Iosevka:size=13
      pad=12x10
      resize-delay-ms=0

      [colors]
      foreground=e8eaed
      background=0d1017
      regular0=0d1017
      regular1=eb6f92
      regular2=a9dc76
      regular3=f6c177
      regular4=9ccfd8
      regular5=c4a7e7
      regular6=95d3d0
      regular7=e8eaed
      bright0=6e7687
      bright1=ff8aa3
      bright2=c3e88d
      bright3=ffd28f
      bright4=b9e7ef
      bright5=d6b4ff
      bright6=a8e6e2
      bright7=ffffff
    '';

    home.file.".config/fuzzel/fuzzel.ini".text = ''
      font=Iosevka:size=14
      width=48
      lines=12
      tabs=4
      horizontal-pad=18
      vertical-pad=14
      inner-pad=8
      layer=overlay

      [colors]
      background=0d1017f2
      text=e8eaedff
      match=9ccfd8ff
      selection=1a2130ff
      selection-text=ffffffff
      selection-match=9ccfd8ff
      border=9ccfd8ff

      [border]
      width=2
      radius=8
    '';

    home.file.".config/mako/config".text = ''
      font=Iosevka 12
      background-color=#0d1017f2
      text-color=#e8eaed
      border-color=#9ccfd8
      border-size=2
      border-radius=8
      padding=12
      margin=16
      width=420
      default-timeout=6000
      anchor=top-right
    '';

    gtk = {
      enable = true;
      theme = {
        name = "adw-gtk3-dark";
        package = pkgs.adw-gtk3;
      };
      gtk4.theme = {
        name = "adw-gtk3-dark";
        package = pkgs.adw-gtk3;
      };
      iconTheme = {
        name = "Papirus-Dark";
        package = pkgs.papirus-icon-theme;
      };
      cursorTheme = {
        name = "Bibata-Modern-Ice";
        package = pkgs.bibata-cursors;
        size = 24;
      };
      gtk3.extraConfig.gtk-application-prefer-dark-theme = 1;
      gtk4.extraConfig.gtk-application-prefer-dark-theme = 1;
    };

    home.pointerCursor = {
      gtk.enable = true;
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Ice";
      size = 24;
    };

    dconf.settings."org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      gtk-theme = "adw-gtk3-dark";
      icon-theme = "Papirus-Dark";
      cursor-theme = "Bibata-Modern-Ice";
    };

    xdg.mimeApps = {
      enable = true;
      defaultApplications = {
        "text/html" = ["firefox.desktop"];
        "x-scheme-handler/http" = ["firefox.desktop"];
        "x-scheme-handler/https" = ["firefox.desktop"];
      };
    };
  };
}
