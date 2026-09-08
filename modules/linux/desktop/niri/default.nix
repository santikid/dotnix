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
  scripts = import ./lib/scripts.nix {
    inherit browserPackage config lib pkgs theme;
  };
  binds = import ./lib/binds.nix {
    inherit lib;
    inherit (scripts) commands lockCommand;
  };
  niri = scripts // binds;
in {
  imports = [(import ./noctalia.nix {inherit theme user;})];

  environment.systemPackages = [
    browserPackage
    pkgs.grim
    pkgs.imv
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

  programs.dconf.enable = true;
  services.displayManager.regreet = {
    enable = true;
    theme = {
      name = "adw-gtk3-dark";
      package = pkgs.adw-gtk3;
    };
    font = {
      name = theme.fonts.ui;
      package = pkgs.inter;
      size = 12;
    };
    cursorTheme = {
      name = theme.cursor.name;
      package = pkgs.bibata-cursors;
    };
    settings.GTK.application_prefer_dark_theme = true;
    extraCss = ''
      window { background-color: ${theme.colors.desktop}; }
    '';
  };
  systemd.services.greetd.environment = {
    XKB_DEFAULT_LAYOUT = "de";
    XKB_DEFAULT_VARIANT = "mac";
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
