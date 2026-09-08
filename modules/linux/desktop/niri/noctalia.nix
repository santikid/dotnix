# Shared by the Razer and Asahi Niri desktops.
{
  theme,
  user,
}: {
  config,
  pkgs,
  ...
}: let
  noctaliaPackage = config.programs.noctalia.package;
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
        "network"
        "volume"
        "brightness"
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
      network.show_label = false;
      volume = {
        device = "output";
        show_label = true;
      };
      brightness.show_label = false;
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
in {
  programs.noctalia = {
    enable = true;
    systemd.enable = true;
    recommendedServices.enable = true;
  };

  home-manager.users.${user.name} = {
    config,
    lib,
    ...
  }: {
    programs.noctalia = {
      enable = true;
      package = noctaliaPackage;
      settings = noctaliaConfig;
      customPalettes.Graphite = noctaliaPalette;
    };

    # Noctalia loads this layer last. Pin it too, so old GUI overrides cannot
    # change the flake's design. Device controls (volume, Wi-Fi, etc.) still work.
    home.file."${config.xdg.stateHome}/noctalia/settings.toml".source =
      config.xdg.configFile."noctalia/config.toml".source;

    # Preserve existing GUI preferences before Home Manager takes ownership.
    home.activation.backupNoctaliaSettings = lib.hm.dag.entryBefore ["checkLinkTargets"] ''
      settings=${lib.escapeShellArg "${config.xdg.stateHome}/noctalia/settings.toml"}
      if [ -e "$settings" ] && [ ! -L "$settings" ]; then
        backup="$settings.before-declarative.$(${pkgs.coreutils}/bin/date +%s%N)"
        run ${pkgs.coreutils}/bin/mv -- "$settings" "$backup"
      fi
    '';
  };
}
