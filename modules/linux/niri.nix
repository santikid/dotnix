{
  config,
  pkgs,
  user,
  ...
}: {
  environment.systemPackages = with pkgs; [
    firefox
    fuzzel
    ghostty
    grim
    kdePackages.dolphin
    mako
    playerctl
    slurp
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

  services.greetd = {
    enable = true;
    settings.default_session = {
      command = "${config.programs.niri.package}/bin/niri-session";
      user = user.name;
    };
  };

  security.pam.services.swaylock = {};
  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };

  environment.sessionVariables = {
    MOZ_ENABLE_WAYLAND = "1";
    NIXOS_OZONE_WL = "1";
    QT_QPA_PLATFORM = "wayland";
    XDG_CURRENT_DESKTOP = "niri";
  };

  xdg.portal = {
    enable = true;
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
      spawn-at-startup "waybar"

      hotkey-overlay {
          skip-at-startup
      }

      prefer-no-csd
      screenshot-path "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png"

      binds {
          Mod+Shift+Slash { show-hotkey-overlay; }

          Mod+T { spawn "ghostty"; }
          Mod+D { spawn "fuzzel"; }
          Mod+C { spawn "firefox"; }
          Mod+F { spawn "dolphin"; }
          Super+Alt+L { spawn "swaylock"; }

          XF86AudioRaiseVolume allow-when-locked=true { spawn-sh "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1+ -l 1.0"; }
          XF86AudioLowerVolume allow-when-locked=true { spawn-sh "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1-"; }
          XF86AudioMute allow-when-locked=true { spawn-sh "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"; }
          XF86AudioMicMute allow-when-locked=true { spawn-sh "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"; }

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
        "height": 28,
        "modules-left": ["niri/workspaces"],
        "modules-center": ["niri/window"],
        "modules-right": ["network", "pulseaudio", "clock"],
        "niri/workspaces": {
          "format": "{icon}",
          "format-icons": {
            "active": "*",
            "default": "."
          }
        },
        "network": {
          "format-ethernet": "{ifname}",
          "format-wifi": "{essid}",
          "format-disconnected": "offline"
        },
        "pulseaudio": {
          "format": "{volume}%",
          "format-muted": "muted"
        },
        "clock": {
          "format": "{:%H:%M}"
        }
      }
    '';

    home.file.".config/waybar/style.css".text = ''
      * {
        border: none;
        border-radius: 0;
        font-family: Iosevka, monospace;
        font-size: 12px;
        min-height: 0;
      }

      window#waybar {
        background: #101010;
        color: #f8f8f2;
      }

      #workspaces,
      #window,
      #network,
      #pulseaudio,
      #clock {
        padding: 0 10px;
      }

      #workspaces button {
        color: #727072;
        padding: 0 4px;
      }

      #workspaces button.active {
        color: #a9dc76;
      }
    '';
  };
}
