{
  config,
  pkgs,
  inputs,
  ...
}: {
  home-manager.users.santi = {
    config,
    pkgs,
    ...
  }: {
    imports = [ ../shared/home ];

    wayland.windowManager.hyprland.enable = true;
    wayland.windowManager.hyprland.settings = {
      exec-once = "waybar & hyprpaper";
      env = [
        "XCURSOR_SIZE,24"
        "QR_QPA_PLATFORMTHEME,qt5ct"
      ];
      input = {
        kb_layout = "de";
        kb_variant = "mac";
      };
      general = {
        gaps_in = 5;
        gaps_out = 5;
        border_size = 1;
        layout = "dwindle";
      };
      decoration = {
        rounding = 10;
        blur = {
          enabled = true;
          size = 3;
          passes = 1;
        };
        drop_shadow = "yes";
        shadow_range = 4;
        shadow_render_power = 3;
        "col.shadow" = "rgba(1a1a1aee)";
      };
      animations = {
        enabled = "no";
      };
      dwindle = {
        pseudotile = "yes";
        preserve_split = "yes";
      };
      misc = {
        force_default_wallpaper = 0;
      };
      windowrulev2 = "suppressevent maximize, class:.*";

      "$mod" = "SUPER";
      bind = 
      [
        "$mod, T, exec, alacritty"
        "$mod, C, exec, firefox"
        "$mod, F, exec, dolphin"
        "$mod, D, exec, wofi --show drun"
        "$mod, P, pseudo"
        "$mod, J, togglesplit"
        "$mod, Q, killactive"
        "$mod, M, exit"
        "$mod, V, togglefloating"

        "$mod, h, movefocus, l"
        "$mod, l, movefocus, r"
        "$mod, k, movefocus, u"
        "$mod, j, movefocus, d"

        "$mod SHIFT, h, movewindow, l"
        "$mod SHIFT, l, movewindow, r"
        "$mod SHIFT, k, movewindow, u"
        "$mod SHIFT, j, movewindow, d"

        "$mod, 1, workspace, 1"
        "$mod, 2, workspace, 2"
        "$mod, 3, workspace, 3"
        "$mod, 4, workspace, 4"
        "$mod, 5, workspace, 5"
        "$mod, 6, workspace, 6"
        "$mod, 7, workspace, 7"
        "$mod, 8, workspace, 8"
        "$mod, 9, workspace, 9"

        "$mod SHIFT, 1, movetoworkspace, 1"
        "$mod SHIFT, 2, movetoworkspace, 2"
        "$mod SHIFT, 3, movetoworkspace, 3"
        "$mod SHIFT, 4, movetoworkspace, 4"
        "$mod SHIFT, 5, movetoworkspace, 5"
        "$mod SHIFT, 6, movetoworkspace, 6"
        "$mod SHIFT, 7, movetoworkspace, 7"
        "$mod SHIFT, 8, movetoworkspace, 8"
        "$mod SHIFT, 9, movetoworkspace, 9"

        "$mod, s, togglespecialworkspace, magic"
        "$mod SHIFT, s, movetoworkspace, special:magic"
      ];
      bindm = [
        # mouse movements
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
        "$mod ALT, mouse:272, resizewindow"
      ];
    };

    programs.zsh = {
      enable = true;
      initExtra = ''
        autoload -U compinit; compinit
        _comp_options+=(globdots) # With hidden files

        setopt AUTO_PUSHD           # Push the current directory visited on the stack.
        setopt PUSHD_IGNORE_DUPS    # Do not store duplicates in the stack.
        setopt PUSHD_SILENT         # Do not print the directory stack after pushd or popd.

        zstyle ':completion:*' file-sort date
        zstyle ':completion:*' menu yes=long select

        bindkey -v
        autoload -U up-line-or-beginning-search
        autoload -U down-line-or-beginning-search
        zle -N up-line-or-beginning-search
        zle -N down-line-or-beginning-search
        bindkey "^[[A" up-line-or-beginning-search # Up
        bindkey "^[[B" down-line-or-beginning-search # Down
      '';
    };
    home.file = {
      ".config/nvim" = {
        source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.nix/configs/nvim";
      };
      ".config/waybar" = {
        source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.nix/configs/waybar";
      };
      ".config/hypr/hyprpaper.conf" = {
        text = ''
preload = $HOME/.nix/wallpaper.png
wallpaper = eDP-1,$HOME/.nix/wallpaper.png
        '';
      };
      ".config/alacritty/alacritty.toml" = {
        source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.nix/configs/alacritty.toml";
      };
    };
  };
}
