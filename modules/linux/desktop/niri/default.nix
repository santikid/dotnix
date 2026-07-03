{
  config,
  inputs,
  lib,
  pkgs,
  user,
  ...
}: let
  ghosttyPalette = [
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
    ghostty = {
      themeName = "graphite-night";
      theme = {
        palette = ghosttyPalette;
        background = "111318";
        foreground = "f4f7fb";
        cursor-color = "7dd3fc";
        selection-background = "2d3443";
        selection-foreground = "ffffff";
      };
    };
  };
  scripts = import ./lib/scripts.nix {
    inherit config lib pkgs theme;
  };
  binds = import ./lib/binds.nix {
    inherit lib;
    inherit (scripts) commands lockCommand;
  };
  niri = scripts // binds;
in {
  imports = [
    (import ./waybar.nix {inherit niri theme user;})
  ];

  environment.systemPackages = [
    pkgs.brightnessctl
    pkgs.cliphist
    pkgs.fuzzel
    pkgs.grim
    pkgs.imv
    pkgs.localsend
    pkgs.mako
    pkgs.nautilus
    pkgs.networkmanagerapplet
    pkgs.wdisplays
    pkgs.pavucontrol
    pkgs.playerctl
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
  programs.firefox.enable = true;

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
    MOZ_ENABLE_WAYLAND = "1";
    NIXOS_OZONE_WL = "1";
    QT_QPA_PLATFORM = "wayland";
    QT_QPA_PLATFORMTHEME = "gtk3";
    TERMINAL = "ghostty";
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
        ];

        spawn-at-startup = [
          {argv = [niri.commands.mako];}
          {argv = [niri.commands.nmApplet "--indicator"];}
          (niri.cliphistWatcher "text")
          (niri.cliphistWatcher "image")
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
          {argv = [niri.commands.waybar];}
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

    programs.ghostty = {
      enable = true;
      enableZshIntegration = true;
      settings = {
        theme = theme.ghostty.themeName;
        "font-family" = theme.fonts.mono;
        "font-size" = 12;
        "window-padding-x" = 12;
        "window-padding-y" = 10;
      };
      themes = {
        ${theme.ghostty.themeName} = theme.ghostty.theme;
      };
    };

    home.file = {
      ".config/fuzzel/fuzzel.ini".text = ''
        font=${theme.fonts.ui}:size=13
        prompt=>
        width=48
        lines=12
        tabs=4
        horizontal-pad=18
        vertical-pad=14
        inner-pad=8
        layer=overlay

        [colors]
        background=${niri.withAlpha theme.colors.bar "f2"}
        text=${niri.withAlpha theme.colors.text "ff"}
        match=ffffffff
        selection=${niri.withAlpha theme.colors.surfaceHover "ff"}
        selection-text=ffffffff
        selection-match=ffffffff
        border=777777ff

        [border]
        width=2
        radius=8
      '';

      ".config/mako/config".text = ''
        font=${theme.fonts.ui} 12
        background-color=${theme.colors.bar}f2
        text-color=${theme.colors.text}
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
      gtk.enable = true;
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
        "inode/directory" = ["org.gnome.Nautilus.desktop"];
        "text/html" = ["firefox.desktop"];
        "x-scheme-handler/http" = ["firefox.desktop"];
        "x-scheme-handler/https" = ["firefox.desktop"];
      };
    };
  };
}
