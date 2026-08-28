{
  config,
  inputs,
  lib,
  pkgs,
  user,
  ...
}: let
  browserPackage = inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default;
  footPalette = [
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
  theme = {
    fonts = {
      ui = "Inter";
      mono = "Iosevka";
    };
    cursor = {
      name = "Bibata-Modern-Ice";
      size = 24;
    };
    colors = {
      desktop = "#111214";
      bar = "#18191c";
      barBorder = "#2d2f34";
      surface = "#212327";
      surfaceHover = "#2b2d32";
      text = "#f0f1f3";
      muted = "#9b9da3";
      dim = "#63666d";
      selected = "#d5d7da";
      accent = "#d5d7da";
      warning = "#d5ad75";
      critical = "#dc7b82";
      focusInactive = "#55585f";
    };
    foot = {
      palette = footPalette;
      background = "111318";
      foreground = "f4f7fb";
      cursor-color = "7dd3fc";
      selection-background = "2d3443";
      selection-foreground = "ffffff";
    };
  };
  noctaliaConfig = {
    shell = {
      font_family = theme.fonts.ui;
      launch_apps_as_systemd_services = true;
      polkit_agent = true;
    };

    wallpaper.enabled = false;

    theme = {
      mode = "dark";
      source = "custom";
      custom_palette = "Graphite";
    };

    notification.enable_daemon = true;
    lockscreen.enabled = false;
    system.monitor.enabled = false;
    hooks.started = "${lib.getExe config.programs.noctalia.package} msg color-scheme-set custom Graphite";

    control_center = {
      sidebar = "compact";
      sidebar_section = "compact";
      width = 720;
      show_shortcut_labels = true;
      show_session_button = true;
      shortcuts = map (type: {inherit type;}) [
        "wifi"
        "bluetooth"
        "audio"
        "caffeine"
        "notification"
        "power_profile"
      ];
    };

    bar.main = {
      position = "top";
      layer = "top";
      thickness = 36;
      background_opacity = 0.94;
      border = "outline";
      border_width = 1.0;
      radius = 12;
      concave_edge_corners = false;
      margin_ends = 12;
      margin_edge = 8;
      padding = 10;
      widget_spacing = 6;
      font_weight = 500;
      shadow = true;
      contact_shadow = true;
      auto_hide = false;
      reserve_space = true;
      capsule = false;
      start = ["workspaces"];
      center = ["clock"];
      end = [
        "tray"
        "notifications"
        "battery"
        "control-center"
      ];
    };

    widget = {
      workspaces = {
        style = "focus_hint";
        show_labels = false;
        pill_scale = 0.9;
        active_pill_size = 2.0;
        inactive_pill_size = 0.8;
      };
      clock = {
        format = "{:%a %d %b · %H:%M}";
        tooltip_format = "{:%A, %B %d, %Y}";
      };
      tray = {
        drawer = true;
        drawer_columns = 3;
        hide_passive = true;
      };
      notifications.hide_when_no_unread = true;
      battery = {
        display_mode = "glyph";
        show_label = true;
        label_content = "percent";
      };
      control-center = {
        capsule = true;
        capsule_fill = "primary";
        capsule_foreground = "on_primary";
        capsule_padding = 7;
      };
    };
  };
  noctaliaPalette = {
    dark = {
      mPrimary = "#d6d8dc";
      mOnPrimary = "#17181b";
      mSecondary = "#b4b7bd";
      mOnSecondary = "#17181b";
      mTertiary = "#8e929a";
      mOnTertiary = "#111214";
      mError = "#dc7b82";
      mOnError = "#1b1012";
      mSurface = "#18191c";
      mOnSurface = "#f0f1f3";
      mSurfaceVariant = "#24262a";
      mOnSurfaceVariant = "#b9bcc2";
      mOutline = "#3b3e44";
      mShadow = "#08090a";
      mHover = "#2b2d32";
      mOnHover = "#f4f5f7";
      terminal = {
        background = "#111318";
        foreground = "#f4f7fb";
        cursor = "#d6d8dc";
        cursorText = "#111318";
        selectionBg = "#2d3443";
        selectionFg = "#ffffff";
        normal = {
          black = "#111318";
          red = "#ff7b8a";
          green = "#a7f3d0";
          yellow = "#f6c177";
          blue = "#7dd3fc";
          magenta = "#c4a7e7";
          cyan = "#67e8f9";
          white = "#e6edf3";
        };
        bright = {
          black = "#667085";
          red = "#ff9aa6";
          green = "#c4f8df";
          yellow = "#ffd899";
          blue = "#a5e4ff";
          magenta = "#d8b4fe";
          cyan = "#9bf6ff";
          white = "#ffffff";
        };
      };
    };
  };
  noctaliaConfigFile = (pkgs.formats.toml {}).generate "noctalia-config.toml" noctaliaConfig;
  noctaliaPaletteFile = (pkgs.formats.json {}).generate "Graphite.json" noctaliaPalette;
  scripts = import ./lib/scripts.nix {
    inherit browserPackage config lib pkgs theme;
  };
  binds = import ./lib/binds.nix {
    inherit lib;
    inherit (scripts) commands lockCommand;
  };
  niri = scripts // binds;
in {
  environment.systemPackages = [
    browserPackage
    pkgs.grim
    pkgs.imv
    pkgs.localsend
    pkgs.nautilus
    pkgs.wdisplays
    pkgs.slurp
    pkgs.swayidle
    pkgs.swaylock
    pkgs.wl-clipboard
    pkgs.xdg-utils
    pkgs.xwayland-satellite
  ];

  programs.niri = {
    enable = true;
    useNautilus = true;
  };

  programs.noctalia = {
    enable = true;
    systemd.enable = true;
    recommendedServices.enable = true;
  };

  programs.dconf.enable = true;
  services.greetd = {
    enable = true;
    settings.default_session.command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --remember-user-session --cmd ${config.programs.niri.package}/bin/niri-session";
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
    BROWSER = niri.commands.browser;
    MOZ_ENABLE_WAYLAND = "1";
    NIXOS_OZONE_WL = "1";
    QT_QPA_PLATFORM = "wayland";
    QT_QPA_PLATFORMTHEME = "gtk3";
    TERMINAL = "foot";
    XDG_CURRENT_DESKTOP = "niri";
    XCURSOR_SIZE = toString niri.cursor.size;
    XCURSOR_THEME = niri.cursor.name;
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
        debug.honor-xdg-activation-with-invalid-serial = {};

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
          background-color = theme.colors.desktop;
          backdrop-color = theme.colors.desktop;
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
          focus-ring.enable = false;
          border = {
            enable = true;
            width = 2;
            active.color = theme.colors.selected;
            inactive.color = theme.colors.focusInactive;
            urgent.color = theme.colors.critical;
          };
        };

        window-rules = [
          {draw-border-with-background = false;}
          {
            matches = [{app-id = "^dev\\.noctalia\\.Noctalia$";}];
            open-floating = true;
            default-column-width.fixed = 1080;
            default-window-height.fixed = 920;
          }
        ];

        spawn-at-startup = [
          {
            argv = [
              niri.commands.swayidle
              "-w"
              "timeout"
              "600"
              niri.lockCommand
              "timeout"
              "660"
              "${niri.commands.niri} msg action power-off-monitors"
              "before-sleep"
              niri.lockCommand
            ];
          }
          {argv = [niri.commands.tailscale "systray"];}
          {argv = [niri.commands.xwaylandSatellite];}
        ];

        hotkey-overlay.skip-at-startup = true;
        cursor = {
          theme = theme.cursor.name;
          inherit (theme.cursor) size;
        };
        prefer-no-csd = true;
        screenshot-path = "~/Pictures/Screenshots/Screenshot from %Y-%m-%d %H-%M-%S.png";
        binds = niri.baseBinds // niri.mediaBinds // niri.workspaceBinds;
      };
    };

    programs.foot = {
      enable = true;
      settings = {
        main = {
          font = "${theme.fonts.mono}:size=12";
          pad = "12x10";
          term = "foot";
        };
        colors-dark =
          {
            background = theme.foot.background;
            foreground = theme.foot.foreground;
          }
          // lib.listToAttrs (map (entry: let
              split = lib.splitString "=" entry;
            in {
              name = builtins.head split;
              value = lib.removePrefix "#" (builtins.elemAt split 1);
            })
            theme.foot.palette);
      };
    };

    home.file = {
      ".config/noctalia/config.toml".source = noctaliaConfigFile;
      ".config/noctalia/palettes/Graphite.json".source = noctaliaPaletteFile;
    };

    gtk = {
      enable = true;
      font = {
        name = theme.fonts.ui;
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
        name = theme.cursor.name;
        package = pkgs.bibata-cursors;
        inherit (theme.cursor) size;
      };
      gtk3.extraConfig.gtk-application-prefer-dark-theme = 1;
      gtk4.extraConfig.gtk-application-prefer-dark-theme = 1;
    };

    home.pointerCursor = {
      enable = true;
      package = pkgs.bibata-cursors;
      name = theme.cursor.name;
      inherit (theme.cursor) size;
    };

    dconf.settings."org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      gtk-theme = "adw-gtk3-dark";
      icon-theme = "Papirus-Dark";
      cursor-theme = theme.cursor.name;
      document-font-name = "${theme.fonts.ui} 11";
      font-name = "${theme.fonts.ui} 11";
      monospace-font-name = "${theme.fonts.mono} 11";
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
        "application/vnd.mozilla.xul+xml" = ["zen-beta.desktop"];
        "application/xhtml+xml" = ["zen-beta.desktop"];
        "inode/directory" = ["org.gnome.Nautilus.desktop"];
        "text/html" = ["zen-beta.desktop"];
        "x-scheme-handler/http" = ["zen-beta.desktop"];
        "x-scheme-handler/https" = ["zen-beta.desktop"];
      };
    };
  };
}
