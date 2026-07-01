{
  config,
  inputs,
  lib,
  pkgs,
  user,
  ...
}: let
  uiFont = "Inter";
  monoFont = "Iosevka";
  cursor = {
    name = "Bibata-Modern-Ice";
    size = 24;
  };

  colors = {
    desktop = "#111318";
    bar = "#171a21";
    barBorder = "#2b303b";
    surface = "#222734";
    surfaceHover = "#2d3443";
    text = "#f4f7fb";
    muted = "#9aa7b8";
    selected = "#7dd3fc";
    selectedText = "#071118";
    accent = "#a7f3d0";
    warning = "#f6c177";
    critical = "#ff7b8a";
    focusInactive = "#667085";
  };

  icons = {
    overview = "󰕰";
    clipboard = "";
    idleActive = "";
    idleInactive = "";
    power = "";
    brightness = ["󰃞" "󰃟" "󰃠"];
    volumeMuted = "󰝟";
    volume = ["" "" ""];
    battery = ["" "" "" "" ""];
    plugged = "";
    workspace = {
      focused = "";
      active = "";
      urgent = "";
      empty = "";
      default = "";
    };
  };

  waybarModules = {
    left = ["niri/workspaces" "custom/overview"];
    center = [];
    right = [
      "tray"
      "custom/clipboard"
      "idle_inhibitor"
      "custom/power-profile"
      "backlight"
      "pulseaudio"
      "custom/battery"
      "clock"
    ];
  };

  waybarStyledSelectors = [
    "#workspaces"
    "#custom-overview"
    "#custom-clipboard"
    "#idle_inhibitor"
    "#tray"
    "#custom-power-profile"
    "#backlight"
    "#pulseaudio"
    "#custom-battery"
    "#clock"
  ];
  cssSelector = selectors: lib.concatStringsSep ",\n" (map (selector: "        ${selector}") selectors);

  lockColor = lib.removePrefix "#" colors.desktop;
  hex = color: lib.removePrefix "#" color;
  withAlpha = color: alpha: "${hex color}${alpha}";

  swaylockBin = lib.getExe pkgs.swaylock;
  lockCommand = lib.concatStringsSep " " [
    swaylockBin
    "-f"
    "-c"
    "${hex colors.bar}"
    "--ignore-empty-password"
    "--show-failed-attempts"
    "--font"
    uiFont
    "--font-size"
    "16"
    "--indicator-idle-visible"
    "--indicator-radius"
    "92"
    "--indicator-thickness"
    "7"
    "--ring-color"
    "${hex colors.surface}"
    "--ring-ver-color"
    "${hex colors.warning}"
    "--ring-wrong-color"
    "${hex colors.critical}"
    "--ring-clear-color"
    "${hex colors.muted}"
    "--key-hl-color"
    "${hex colors.selected}"
    "--bs-hl-color"
    "${hex colors.critical}"
    "--inside-color"
    "${withAlpha colors.bar "cc"}"
    "--inside-ver-color"
    "${withAlpha colors.bar "cc"}"
    "--inside-wrong-color"
    "${withAlpha colors.bar "cc"}"
    "--inside-clear-color"
    "${withAlpha colors.bar "cc"}"
    "--line-color"
    "${withAlpha colors.barBorder "00"}"
    "--separator-color"
    "${withAlpha colors.barBorder "00"}"
    "--text-color"
    "${hex colors.text}"
    "--text-ver-color"
    "${hex colors.text}"
    "--text-wrong-color"
    "${hex colors.critical}"
    "--text-clear-color"
    "${hex colors.text}"
  ];

  screenshot = pkgs.writeShellApplication {
    name = "screenshot";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.grim
      pkgs.libnotify
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
          grim - | tee "$file" | wl-copy --type image/png
          ;;
        area)
          geometry="$(slurp)" || exit 0
          [[ -n "$geometry" ]] || exit 0
          grim -g "$geometry" - | tee "$file" | wl-copy --type image/png
          ;;
        *)
          echo "usage: screenshot [full|area]" >&2
          exit 64
          ;;
      esac

      notify-send --app-name=screenshot "Screenshot copied" "$(basename "$file")"
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

  waybarBattery = pkgs.writeShellApplication {
    name = "waybar-battery";
    text = ''
      find_battery() {
        for candidate in \
          /sys/class/power_supply/macsmc-battery \
          /sys/class/power_supply/BAT0 \
          /sys/class/power_supply/BAT1 \
          /sys/class/power_supply/battery; do
          [[ -r "$candidate/capacity" ]] || continue
          printf '%s\n' "$candidate"
          return
        done

        for candidate in /sys/class/power_supply/*; do
          [[ -r "$candidate/type" ]] || continue
          [[ "$(<"$candidate/type")" == "Battery" ]] || continue
          [[ -r "$candidate/capacity" ]] || continue
          printf '%s\n' "$candidate"
          return
        done
      }

      battery="$(find_battery)"

      if [[ -z "$battery" || ! -r "$battery/capacity" ]]; then
        printf '{"text":"","tooltip":"Battery unavailable","class":"missing"}\n'
        exit 0
      fi

      capacity="$(<"$battery/capacity")"
      status="Unknown"
      [[ -r "$battery/status" ]] && status="$(<"$battery/status")"

      class=""
      if [[ "$status" == "Charging" ]]; then
        icon="${icons.power}"
        class="charging"
      elif [[ "$status" == "Full" || "$status" == "Not charging" ]]; then
        icon="${icons.plugged}"
        class="plugged"
      elif (( capacity <= 15 )); then
        icon="${builtins.elemAt icons.battery 0}"
        class="critical"
      elif (( capacity <= 30 )); then
        icon="${builtins.elemAt icons.battery 1}"
        class="warning"
      elif (( capacity <= 60 )); then
        icon="${builtins.elemAt icons.battery 2}"
      elif (( capacity <= 85 )); then
        icon="${builtins.elemAt icons.battery 3}"
      else
        icon="${builtins.elemAt icons.battery 4}"
      fi

      printf '{"text":"%s %s%%","tooltip":"%s","class":"%s"}\n' "$icon" "$capacity" "$status" "$class"
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
    tailscale = lib.getExe pkgs.tailscale;
    terminal = lib.getExe pkgs.ghostty;
    waybar = lib.getExe pkgs.waybar;
    waybarBattery = lib.getExe waybarBattery;
    wlPaste = lib.getExe' pkgs.wl-clipboard "wl-paste";
    wpctl = lib.getExe' pkgs.wireplumber "wpctl";
    xwaylandSatellite = lib.getExe pkgs.xwayland-satellite;
    nmApplet = lib.getExe pkgs.networkmanagerapplet;
    nmConnectionEditor = lib.getExe' pkgs.networkmanagerapplet "nm-connection-editor";
  };

  cliphistWatcher = type: {
    argv = [
      pkgs.runtimeShell
      "-c"
      "${commands.wlPaste} --type ${type} --watch ${commands.cliphist} store"
    ];
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
      name = "${modifier}+Shift+${toString workspace}";
      value = bind {move-column-to-workspace = workspace;};
    }
  ]) (lib.range 1 9)));

  directionalBinds = mapBinds {
    "${modifier}+H" = {focus-column-left = [];};
    "${modifier}+J" = {focus-window-down = [];};
    "${modifier}+K" = {focus-window-up = [];};
    "${modifier}+L" = {focus-column-right = [];};
    "${modifier}+Shift+H" = {move-column-left = [];};
    "${modifier}+Shift+J" = {move-window-down = [];};
    "${modifier}+Shift+K" = {move-window-up = [];};
    "${modifier}+Shift+L" = {move-column-right = [];};
    "${modifier}+U" = {focus-workspace-down = [];};
    "${modifier}+I" = {focus-workspace-up = [];};
    "${modifier}+Shift+U" = {move-column-to-workspace-down = [];};
    "${modifier}+Shift+I" = {move-column-to-workspace-up = [];};
  };

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
    "${modifier}+C" = [commands.browser];
    "${modifier}+F" = [commands.files];
    "${modifier}+Shift+V" = [commands.clipboardMenu];
    "${modifier}+Escape" = [commands.sessionMenu];
    "${modifier}+Ctrl+3" = [commands.screenshot "full"];
    "${modifier}+Ctrl+4" = [commands.screenshot "area"];
    "Alt+Print" = [commands.screenshot "area"];
  } // {
    "${modifier}+Ctrl+Q" = spawnSh lockCommand;
    "Super+Alt+L" = spawnSh lockCommand;
  };

  actionBinds = mapBinds {
    "${modifier}+Shift+Slash" = {show-hotkey-overlay = [];};
    "${modifier}+BracketLeft" = {consume-or-expel-window-left = [];};
    "${modifier}+BracketRight" = {consume-or-expel-window-right = [];};
    "${modifier}+R" = {switch-preset-column-width = [];};
    "${modifier}+Shift+R" = {switch-preset-column-width-back = [];};
    "${modifier}+M" = {maximize-window-to-edges = [];};
    "${modifier}+Ctrl+Space" = {toggle-window-floating = [];};
    "${modifier}+Shift+F" = {fullscreen-window = [];};
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

  baseBinds = applicationBinds // directionalBinds // actionBinds // parameterBinds // repeatlessBinds;
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
    nwg-displays
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
            dwt = true;
          };
          focus-follows-mouse = {
            enable = true;
            max-scroll-amount = "0%";
          };
          warp-mouse-to-focus.enable = true;
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
            enable = false;
          };
          border = {
            enable = true;
            width = 2;
            active.color = colors.selected;
            inactive.color = colors.focusInactive;
            urgent.color = colors.critical;
          };
        };

        window-rules = [
          {draw-border-with-background = false;}
        ];

        spawn-at-startup = [
          {argv = [commands.mako];}
          {argv = [commands.nmApplet "--indicator"];}
          (cliphistWatcher "text")
          (cliphistWatcher "image")
          {
            argv = [
              commands.swayidle
              "-w"
              "timeout"
              "600"
              lockCommand
              "timeout"
              "660"
              "${commands.niri} msg action power-off-monitors"
              "before-sleep"
              lockCommand
            ];
          }
          {argv = [commands.waybar];}
          {argv = [commands.tailscale "systray"];}
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
        theme = "graphite-night";
        "font-family" = monoFont;
        "font-size" = 12;
        "window-padding-x" = 12;
        "window-padding-y" = 10;
      };
      themes."graphite-night" = {
        palette = [
          "0=#111318"
          "1=#ff7b8a"
          "2=#a7f3d0"
          "3=#f6c177"
          "4=#7dd3fc"
          "5=#c4a7e7"
          "6=#67e8f9"
          "7=#e6edf3"
          "8=#667085"
          "9=#ff9aa6"
          "10=#c4f8df"
          "11=#ffd899"
          "12=#a5e4ff"
          "13=#d8b4fe"
          "14=#9bf6ff"
          "15=#ffffff"
        ];
        background = "111318";
        foreground = "f4f7fb";
        cursor-color = "7dd3fc";
        selection-background = "2d3443";
        selection-foreground = "ffffff";
      };
    };

    programs.waybar = {
      enable = true;
      settings.mainBar = {
        layer = "top";
        position = "top";
        height = 40;
        spacing = 7;
        "modules-left" = waybarModules.left;
        "modules-center" = waybarModules.center;
        "modules-right" = waybarModules.right;

        "niri/workspaces" = {
          format = "{icon}";
          "format-icons" = icons.workspace;
        };
        "custom/overview" = {
          format = icons.overview;
          tooltip = false;
          "on-click" = "${commands.niri} msg action toggle-overview";
        };
        tray = {
          spacing = 10;
        };
        "custom/clipboard" = {
          format = icons.clipboard;
          tooltip = true;
          "tooltip-format" = "Clipboard history";
          "on-click" = commands.clipboardMenu;
        };
        idle_inhibitor = {
          format = "{icon}";
          "format-icons" = {
            activated = icons.idleActive;
            deactivated = icons.idleInactive;
          };
        };
        "custom/power-profile" = {
          exec = "${commands.powerprofilesctl} get";
          format = "${icons.power} {}";
          interval = 30;
          tooltip = true;
          "tooltip-format" = "Power profile";
          "on-click" = commands.powerProfileMenu;
        };
        backlight = {
          format = "{icon} {percent}%";
          "format-icons" = icons.brightness;
          "on-scroll-up" = "${commands.brightnessctl} set +5%";
          "on-scroll-down" = "${commands.brightnessctl} set 5%-";
        };
        pulseaudio = {
          format = "{icon} {volume}%";
          "format-muted" = icons.volumeMuted;
          "format-icons" = {
            default = icons.volume;
          };
          "on-click" = commands.pavucontrol;
          "on-click-right" = "${commands.wpctl} set-mute @DEFAULT_AUDIO_SINK@ toggle";
          "on-scroll-up" = "${commands.wpctl} set-volume @DEFAULT_AUDIO_SINK@ 0.05+ -l 1.0";
          "on-scroll-down" = "${commands.wpctl} set-volume @DEFAULT_AUDIO_SINK@ 0.05-";
        };
        "custom/battery" = {
          exec = commands.waybarBattery;
          interval = 30;
          "return-type" = "json";
          "on-click" = commands.powerProfileMenu;
        };
        clock = {
          format = "{:%a %b %d  %H:%M}";
          "tooltip-format" = "{:%A, %B %d, %Y}";
        };
      };

      style = ''
        * {
          border: none;
          font-family: ${uiFont}, "Symbols Nerd Font", "Symbols Nerd Font Mono", sans-serif;
          font-size: 12px;
          font-weight: 600;
          min-height: 0;
        }

        window#waybar {
          background: ${colors.bar};
          border-bottom: 1px solid ${colors.barBorder};
          color: ${colors.text};
          padding: 0 12px;
        }

${cssSelector waybarStyledSelectors} {
          margin: 6px 0;
          padding: 0 12px;
          border-radius: 8px;
          background: ${colors.surface};
        }

        #custom-overview:hover,
        #custom-clipboard:hover,
        #custom-power-profile:hover,
        #idle_inhibitor:hover,
        #backlight:hover,
        #workspaces button:hover {
          background: ${colors.surfaceHover};
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
          color: ${colors.muted};
        }

        #workspaces button.active {
          background: ${colors.selected};
          color: ${colors.selectedText};
        }

        #idle_inhibitor,
        #tray {
          color: ${colors.muted};
        }

        #idle_inhibitor.activated,
        #custom-power-profile {
          color: ${colors.accent};
        }

        #clock {
          min-width: 112px;
        }

        #pulseaudio.muted,
        #custom-battery.warning {
          color: ${colors.warning};
        }

        #custom-battery.critical {
          color: ${colors.critical};
        }
      '';
    };

    home.file.".config/fuzzel/fuzzel.ini".text = ''
      font=${uiFont}:size=13
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
      font=${uiFont} 12
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
      font = {
        name = uiFont;
        size = 11;
      };
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
      document-font-name = "${uiFont} 11";
      font-name = "${uiFont} 11";
      monospace-font-name = "${monoFont} 11";
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
