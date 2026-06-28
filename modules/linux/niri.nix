{
  config,
  inputs,
  lib,
  pkgs,
  user,
  ...
}: let
  font = "Iosevka";
  cursor = {
    name = "Bibata-Modern-Ice";
    size = 24;
  };

  colors = {
    desktop = "#eeeeee";
    bar = "#2d2d2d";
    barBorder = "#242424";
    surface = "#3a3a3a";
    surfaceHover = "#484848";
    text = "#f2f2f2";
    muted = "#b8b8b8";
    selected = "#f4f4f4";
    selectedText = "#202020";
    warning = "#d6b25e";
    critical = "#d16d6d";
    focus = "#4a4a4a";
    focusInactive = "#c6c6c6";
  };

  lockColor = lib.removePrefix "#" colors.desktop;
  hex = color: lib.removePrefix "#" color;
  withAlpha = color: alpha: "${hex color}${alpha}";

  swaylockBin = lib.getExe pkgs.swaylock;
  lockCommand = "${swaylockBin} -f -c ${lockColor} --ignore-empty-password --show-failed-attempts";

  screenshot = pkgs.writeShellApplication {
    name = "screenshot";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.grim
      pkgs.slurp
      pkgs.wl-clipboard
    ];
    text = ''
      mode="''${1:-area}"
      dir="''${XDG_SCREENSHOTS_DIR:-$HOME/Pictures/Screenshots}"
      mkdir -p "$dir"

      timestamp="$(date '+%Y-%m-%d %H-%M-%S')"
      file="$dir/Screenshot from $timestamp.png"

      case "$mode" in
        full)
          grim "$file"
          ;;
        area)
          geometry="$(slurp)" || exit 0
          [[ -n "$geometry" ]] || exit 0
          grim -g "$geometry" "$file"
          ;;
        clip)
          geometry="$(slurp)" || exit 0
          [[ -n "$geometry" ]] || exit 0
          grim -g "$geometry" - | wl-copy --type image/png
          ;;
        *)
          echo "usage: screenshot [full|area|clip]" >&2
          exit 64
          ;;
      esac
    '';
  };

  clipboardMenu = pkgs.writeShellApplication {
    name = "clipboard-menu";
    runtimeInputs = [
      pkgs.cliphist
      pkgs.fuzzel
      pkgs.wl-clipboard
    ];
    text = ''
      choice="$(cliphist list | fuzzel --dmenu --prompt 'Clipboard ' --width 72)" || exit 0
      [[ -n "$choice" ]] || exit 0

      printf '%s' "$choice" | cliphist decode | wl-copy
    '';
  };

  sessionMenu = pkgs.writeShellApplication {
    name = "session-menu";
    runtimeInputs = [
      config.programs.niri.package
      pkgs.fuzzel
      pkgs.systemd
    ];
    text = ''
      choice="$(
        printf 'Lock\nSuspend\nLogout\nReboot\nShutdown\n' |
          fuzzel --dmenu --prompt 'Session '
      )" || exit 0

      case "$choice" in
        Lock)
          ${lockCommand}
          ;;
        Suspend)
          systemctl suspend
          ;;
        Logout)
          niri msg action quit
          ;;
        Reboot)
          systemctl reboot
          ;;
        Shutdown)
          systemctl poweroff
          ;;
      esac
    '';
  };

  powerProfileMenu = pkgs.writeShellApplication {
    name = "power-profile-menu";
    runtimeInputs = [
      pkgs.fuzzel
      pkgs.power-profiles-daemon
    ];
    text = ''
      current="$(powerprofilesctl get 2>/dev/null || true)"
      choice="$(
        printf 'balanced\npower-saver\nperformance\n' |
          fuzzel --dmenu --prompt "Power ''${current:-unknown} "
      )" || exit 0
      [[ -n "$choice" ]] || exit 0

      powerprofilesctl set "$choice"
    '';
  };

  commands = {
    browser = lib.getExe pkgs.firefox;
    brightnessctl = lib.getExe pkgs.brightnessctl;
    cliphist = lib.getExe pkgs.cliphist;
    clipboardMenu = lib.getExe clipboardMenu;
    files = lib.getExe pkgs.nautilus;
    fuzzel = lib.getExe pkgs.fuzzel;
    mako = lib.getExe pkgs.mako;
    niri = lib.getExe config.programs.niri.package;
    pavucontrol = lib.getExe pkgs.pavucontrol;
    playerctl = lib.getExe pkgs.playerctl;
    powerprofilesctl = lib.getExe' pkgs.power-profiles-daemon "powerprofilesctl";
    powerProfileMenu = lib.getExe powerProfileMenu;
    screenshot = lib.getExe screenshot;
    sessionMenu = lib.getExe sessionMenu;
    swayidle = lib.getExe pkgs.swayidle;
    terminal = lib.getExe pkgs.ghostty;
    waybar = lib.getExe pkgs.waybar;
    wlPaste = lib.getExe' pkgs.wl-clipboard "wl-paste";
    wpctl = lib.getExe' pkgs.wireplumber "wpctl";
    xwaylandSatellite = lib.getExe pkgs.xwayland-satellite;
    bluemanManager = lib.getExe' pkgs.blueman "blueman-manager";
    nmApplet = lib.getExe pkgs.networkmanagerapplet;
    nmConnectionEditor = lib.getExe' pkgs.networkmanagerapplet "nm-connection-editor";
  };

  modifier = "Mod";
  bind = action: {inherit action;};
  spawn = argv: bind {spawn = argv;};
  spawnSh = command: bind {"spawn-sh" = command;};
  locked = binding: binding // {allow-when-locked = true;};
  repeatless = binding: binding // {repeat = false;};
  mapBinds = lib.mapAttrs (_: bind);
  mapSpawnBinds = lib.mapAttrs (_: spawn);

  workspaceBinds = lib.listToAttrs (lib.flatten (map (workspace: [
    {
      name = "${modifier}+${toString workspace}";
      value = bind {focus-workspace = workspace;};
    }
    {
      name = "${modifier}+Ctrl+${toString workspace}";
      value = bind {move-column-to-workspace = workspace;};
    }
  ]) (lib.range 1 9)));

  mediaBinds = {
    XF86AudioRaiseVolume = locked (spawnSh "${commands.wpctl} set-volume @DEFAULT_AUDIO_SINK@ 0.1+ -l 1.0");
    XF86AudioLowerVolume = locked (spawnSh "${commands.wpctl} set-volume @DEFAULT_AUDIO_SINK@ 0.1-");
    XF86AudioMute = locked (spawnSh "${commands.wpctl} set-mute @DEFAULT_AUDIO_SINK@ toggle");
    XF86AudioMicMute = locked (spawnSh "${commands.wpctl} set-mute @DEFAULT_AUDIO_SOURCE@ toggle");
    XF86AudioPlay = locked (spawn [commands.playerctl "play-pause"]);
    XF86AudioPause = locked (spawn [commands.playerctl "play-pause"]);
    XF86AudioNext = locked (spawn [commands.playerctl "next"]);
    XF86AudioPrev = locked (spawn [commands.playerctl "previous"]);
    XF86AudioStop = locked (spawn [commands.playerctl "stop"]);
    XF86MonBrightnessUp = locked (spawn [commands.brightnessctl "set" "+5%"]);
    XF86MonBrightnessDown = locked (spawn [commands.brightnessctl "set" "5%-"]);
  };

  applicationBinds = mapSpawnBinds {
    "${modifier}+Space" = [commands.fuzzel];
    "${modifier}+T" = [commands.terminal];
    "${modifier}+Return" = [commands.terminal];
    "${modifier}+D" = [commands.fuzzel];
    "${modifier}+C" = [commands.browser];
    "${modifier}+F" = [commands.files];
    "${modifier}+Shift+V" = [commands.clipboardMenu];
    "${modifier}+Escape" = [commands.sessionMenu];
    "${modifier}+Shift+3" = [commands.screenshot "full"];
    "${modifier}+Shift+4" = [commands.screenshot "area"];
    "${modifier}+Ctrl+Shift+4" = [commands.screenshot "clip"];
    Print = [commands.screenshot "full"];
    "Shift+Print" = [commands.screenshot "area"];
    "Ctrl+Print" = [commands.screenshot "clip"];
  } // {
    "${modifier}+Ctrl+Q" = spawnSh lockCommand;
    "Super+Alt+L" = spawnSh lockCommand;
  };

  actionBinds = mapBinds {
    "${modifier}+Shift+Slash" = {show-hotkey-overlay = [];};
    "${modifier}+H" = {focus-column-left = [];};
    "${modifier}+J" = {focus-window-down = [];};
    "${modifier}+K" = {focus-window-up = [];};
    "${modifier}+L" = {focus-column-right = [];};
    "${modifier}+Ctrl+H" = {move-column-left = [];};
    "${modifier}+Ctrl+J" = {move-window-down = [];};
    "${modifier}+Ctrl+K" = {move-window-up = [];};
    "${modifier}+Ctrl+L" = {move-column-right = [];};
    "${modifier}+U" = {focus-workspace-down = [];};
    "${modifier}+I" = {focus-workspace-up = [];};
    "${modifier}+Ctrl+U" = {move-column-to-workspace-down = [];};
    "${modifier}+Ctrl+I" = {move-column-to-workspace-up = [];};
    "${modifier}+BracketLeft" = {consume-or-expel-window-left = [];};
    "${modifier}+BracketRight" = {consume-or-expel-window-right = [];};
    "${modifier}+R" = {switch-preset-column-width = [];};
    "${modifier}+Shift+R" = {switch-preset-column-width-back = [];};
    "${modifier}+M" = {maximize-window-to-edges = [];};
    "${modifier}+Ctrl+Space" = {toggle-window-floating = [];};
    "${modifier}+Ctrl+F" = {fullscreen-window = [];};
    "${modifier}+Shift+F" = {fullscreen-window = [];};
    "Alt+Print" = {screenshot-window = [];};
    "${modifier}+Shift+Escape" = {toggle-keyboard-shortcuts-inhibit = [];};
    "${modifier}+Shift+P" = {power-off-monitors = [];};
    "${modifier}+Shift+E" = {quit = [];};
    "Ctrl+Alt+Delete" = {quit = [];};
  };

  parameterBinds = mapBinds {
    "${modifier}+Minus" = {set-column-width = "-10%";};
    "${modifier}+Equal" = {set-column-width = "+10%";};
  };

  repeatlessBinds = {
    "${modifier}+Tab" = repeatless (bind {toggle-overview = [];});
    "${modifier}+O" = repeatless (bind {toggle-overview = [];});
    "${modifier}+W" = repeatless (bind {close-window = [];});
    "${modifier}+Q" = repeatless (bind {close-window = [];});
  };

  baseBinds = applicationBinds // actionBinds // parameterBinds // repeatlessBinds;
in {
  environment.systemPackages = with pkgs; [
    brightnessctl
    cliphist
    fuzzel
    grim
    imv
    localsend
    mako
    nautilus
    networkmanagerapplet
    pavucontrol
    playerctl
    slurp
    swayidle
    swaylock
    wl-clipboard
    xdg-utils
    xwayland-satellite
  ];

  programs.niri = {
    enable = true;
    useNautilus = true;
  };

  programs.dconf.enable = true;
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

  services.gnome.gnome-keyring.enable = true;
  services.gvfs.enable = true;

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
    TERMINAL = "ghostty";
    XDG_CURRENT_DESKTOP = "niri";
    XCURSOR_SIZE = toString cursor.size;
    XCURSOR_THEME = cursor.name;
  };

  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gnome
      pkgs.xdg-desktop-portal-gtk
    ];
    config.niri = {
      default = ["gnome" "gtk"];
      "org.freedesktop.impl.portal.Access" = ["gtk"];
      "org.freedesktop.impl.portal.Notification" = ["gtk"];
      "org.freedesktop.impl.portal.Secret" = ["gnome-keyring"];
    };
  };

  home-manager.users.${user.name} = {
    imports = [
      inputs.niri.homeModules.config
    ];

    programs.niri = {
      package = config.programs.niri.package;
      settings = {
        input = {
          keyboard.xkb = {
            layout = "de";
            variant = "mac";
          };
          touchpad = {
            tap = true;
            natural-scroll = true;
          };
        };

        outputs."eDP-1" = {
          scale = 1.6;
          background-color = colors.desktop;
          backdrop-color = colors.desktop;
        };

        layout = {
          gaps = 8;
          center-focused-column = "never";
          preset-column-widths = [
            {proportion = 0.33333;}
            {proportion = 0.5;}
            {proportion = 0.66667;}
          ];
          default-column-width.proportion = 0.5;
          focus-ring = {
            width = 2;
            active.color = colors.focus;
            inactive.color = colors.focusInactive;
          };
          border.enable = false;
        };

        spawn-at-startup = [
          {argv = [commands.mako];}
          {argv = [commands.nmApplet "--indicator"];}
          {argv = [pkgs.runtimeShell "-c" "${commands.wlPaste} --type text --watch ${commands.cliphist} store"];}
          {argv = [pkgs.runtimeShell "-c" "${commands.wlPaste} --type image --watch ${commands.cliphist} store"];}
          {
            argv = [
              commands.swayidle
              "-w"
              "timeout"
              "900"
              lockCommand
              "before-sleep"
              lockCommand
            ];
          }
          {argv = [commands.waybar];}
          {argv = [commands.xwaylandSatellite];}
        ];

        hotkey-overlay.skip-at-startup = true;
        cursor = {
          theme = cursor.name;
          inherit (cursor) size;
        };
        prefer-no-csd = true;
        screenshot-path = "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png";
        binds = baseBinds // mediaBinds // workspaceBinds;
      };
    };

    programs.ghostty = {
      enable = true;
      enableZshIntegration = true;
      settings = {
        theme = "soft-gray";
        "font-family" = font;
        "font-size" = 12;
        "window-padding-x" = 12;
        "window-padding-y" = 10;
      };
      themes."soft-gray" = {
        palette = [
          "0=#111111"
          "1=#d16d6d"
          "2=#8fa876"
          "3=#d6b25e"
          "4=#b8b8b8"
          "5=#c49ab7"
          "6=#9bb0ad"
          "7=#e8e8e8"
          "8=#5a5a5a"
          "9=#e08a8a"
          "10=#a8be8f"
          "11=#e0c279"
          "12=#d0d0d0"
          "13=#d5b0ca"
          "14=#b7c7c4"
          "15=#ffffff"
        ];
        background = "111111";
        foreground = "eeeeee";
        cursor-color = "eeeeee";
        selection-background = "3a3a3a";
        selection-foreground = "ffffff";
      };
    };

    programs.waybar = {
      enable = true;
      settings.mainBar = {
        layer = "top";
        position = "top";
        height = 42;
        spacing = 8;
        "modules-left" = ["niri/workspaces" "custom/overview" "niri/window"];
        "modules-center" = [];
        "modules-right" = [
          "mpris"
          "tray"
          "custom/clipboard"
          "idle_inhibitor"
          "niri/language"
          "network"
          "bluetooth"
          "custom/power-profile"
          "backlight"
          "pulseaudio"
          "battery"
          "clock"
        ];

        "niri/workspaces" = {
          format = "{index}";
        };
        "custom/overview" = {
          format = "overview";
          tooltip = false;
          "on-click" = "${commands.niri} msg action toggle-overview";
        };
        "niri/window" = {
          format = "{}";
          "max-length" = 72;
        };
        "niri/language" = {
          format = "{}";
        };
        tray = {
          spacing = 10;
        };
        mpris = {
          format = "media {dynamic}";
          "format-paused" = "media paused";
          "dynamic-len" = 28;
          "dynamic-order" = ["title" "artist"];
          "on-click" = "${commands.playerctl} play-pause";
          "on-click-right" = "${commands.playerctl} next";
          "on-scroll-up" = "${commands.playerctl} next";
          "on-scroll-down" = "${commands.playerctl} previous";
        };
        "custom/clipboard" = {
          format = "clip";
          tooltip = true;
          "tooltip-format" = "Clipboard history";
          "on-click" = commands.clipboardMenu;
        };
        idle_inhibitor = {
          format = "{icon}";
          "format-icons" = {
            activated = "awake";
            deactivated = "idle";
          };
        };
        bluetooth = {
          format = "bt {status}";
          "format-disabled" = "bt off";
          "format-off" = "bt off";
          "format-connected" = "bt {num_connections}";
          "tooltip-format" = "{controller_alias}";
          "tooltip-format-connected" = "{controller_alias}: {device_alias}";
          "on-click" = commands.bluemanManager;
        };
        backlight = {
          format = "sun {percent}%";
          "on-scroll-up" = "${commands.brightnessctl} set +5%";
          "on-scroll-down" = "${commands.brightnessctl} set 5%-";
        };
        network = {
          "format-ethernet" = "net {ifname}";
          "format-wifi" = "wifi {essid}";
          "format-disconnected" = "net offline";
          "tooltip-format-wifi" = "{ifname}: {ipaddr}/{cidr} {signalStrength}%";
          "on-click" = commands.nmConnectionEditor;
          "on-click-right" = commands.nmApplet;
        };
        "custom/power-profile" = {
          exec = "${commands.powerprofilesctl} get";
          format = "power {}";
          interval = 30;
          tooltip = true;
          "tooltip-format" = "Power profile";
          "on-click" = commands.powerProfileMenu;
        };
        pulseaudio = {
          format = "vol {volume}%";
          "format-muted" = "vol muted";
          "on-click" = commands.pavucontrol;
          "on-click-right" = "${commands.wpctl} set-mute @DEFAULT_AUDIO_SINK@ toggle";
          "on-scroll-up" = "${commands.wpctl} set-volume @DEFAULT_AUDIO_SINK@ 0.05+ -l 1.0";
          "on-scroll-down" = "${commands.wpctl} set-volume @DEFAULT_AUDIO_SINK@ 0.05-";
        };
        battery = {
          states = {
            warning = 30;
            critical = 15;
          };
          format = "bat {capacity}%";
          "format-charging" = "bat {capacity}%+";
          "format-plugged" = "bat {capacity}%=";
          "on-click" = commands.powerProfileMenu;
        };
        clock = {
          format = "{:%H:%M}";
          "tooltip-format" = "{:%A, %d %B %Y}";
        };
      };

      style = ''
        * {
          border: none;
          font-family: ${font}, sans-serif;
          font-size: 12px;
          min-height: 0;
        }

        window#waybar {
          background: ${colors.bar};
          border-bottom: 1px solid ${colors.barBorder};
          color: ${colors.text};
        }

        #workspaces,
        #custom-overview,
        #window,
        #mpris,
        #custom-clipboard,
        #idle_inhibitor,
        #language,
        #tray,
        #bluetooth,
        #custom-power-profile,
        #backlight,
        #network,
        #pulseaudio,
        #battery,
        #clock {
          margin: 7px 0;
          padding: 0 11px;
          border-radius: 7px;
          background: ${colors.surface};
        }

        #custom-overview:hover,
        #custom-clipboard:hover,
        #custom-power-profile:hover,
        #idle_inhibitor:hover,
        #workspaces button:hover {
          background: ${colors.surfaceHover};
        }

        #workspaces button {
          margin: 0 2px;
          padding: 0 8px;
          border-radius: 6px;
          color: ${colors.muted};
        }

        #workspaces button.active {
          background: ${colors.selected};
          color: ${colors.selectedText};
        }

        #window {
          color: ${colors.text};
        }

        #language,
        #idle_inhibitor,
        #mpris.paused,
        #tray {
          color: ${colors.muted};
        }

        #idle_inhibitor.activated,
        #custom-power-profile {
          color: ${colors.selected};
        }

        #network.disconnected,
        #pulseaudio.muted,
        #battery.warning {
          color: ${colors.warning};
        }

        #battery.critical {
          color: ${colors.critical};
        }
      '';
    };

    home.file.".config/fuzzel/fuzzel.ini".text = ''
      font=${font}:size=13
      prompt=>
      width=48
      lines=12
      tabs=4
      horizontal-pad=18
      vertical-pad=14
      inner-pad=8
      layer=overlay

      [colors]
      background=${withAlpha colors.bar "f2"}
      text=${withAlpha colors.text "ff"}
      match=ffffffff
      selection=${withAlpha colors.surfaceHover "ff"}
      selection-text=ffffffff
      selection-match=ffffffff
      border=777777ff

      [border]
      width=2
      radius=8
    '';

    home.file.".config/mako/config".text = ''
      font=${font} 12
      background-color=${colors.bar}f2
      text-color=${colors.text}
      border-color=#777777
      border-size=2
      border-radius=8
      padding=12
      margin=16
      width=420
      max-icon-size=48
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
        name = cursor.name;
        package = pkgs.bibata-cursors;
        inherit (cursor) size;
      };
      gtk3.extraConfig.gtk-application-prefer-dark-theme = 1;
      gtk4.extraConfig.gtk-application-prefer-dark-theme = 1;
    };

    home.pointerCursor = {
      gtk.enable = true;
      package = pkgs.bibata-cursors;
      name = cursor.name;
      inherit (cursor) size;
    };

    dconf.settings."org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      gtk-theme = "adw-gtk3-dark";
      icon-theme = "Papirus-Dark";
      cursor-theme = cursor.name;
      document-font-name = "${font} 11";
      font-name = "${font} 11";
      monospace-font-name = "${font} 11";
    };

    xdg.userDirs = {
      enable = true;
      createDirectories = true;
      setSessionVariables = true;
      desktop = "$HOME/Desktop";
      documents = "$HOME/Documents";
      download = "$HOME/Downloads";
      music = "$HOME/Music";
      pictures = "$HOME/Pictures";
      publicShare = "$HOME/Public";
      templates = "$HOME/Templates";
      videos = "$HOME/Videos";
      extraConfig = {
        SCREENSHOTS = "$HOME/Pictures/Screenshots";
      };
    };

    xdg.mimeApps = {
      enable = true;
      defaultApplications = {
        "inode/directory" = ["org.gnome.Nautilus.desktop"];
        "text/html" = ["firefox.desktop"];
        "x-scheme-handler/http" = ["firefox.desktop"];
        "x-scheme-handler/https" = ["firefox.desktop"];
      };
    };
  };
}
