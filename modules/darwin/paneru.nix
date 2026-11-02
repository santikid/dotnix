{inputs, ...}: let
  # Mirrors modules/linux/desktop/niri/lib/binds.nix, with niri's Mod mapped to cmd.
  modifier = "cmd";
in {
  imports = [
    inputs.paneru.darwinModules.paneru
  ];

  services.paneru = {
    enable = true;
    settings = {
      options = {
        # niri: focus-follows-mouse + warp-mouse-to-focus
        focus_follows_mouse = true;
        mouse_follows_focus = true;
        # niri: center-focused-column = "never"
        auto_center = false;
        animation_speed = 25;
        # niri: preset-column-widths
        preset_column_widths = [0.4 0.5 0.7 0.9];
        reap_empty_workspaces = true;
        create_virtual_workspace_automatically = true;
      };

      # niri: gaps = 8 (edge padding + half-gap on every window below)
      padding = {
        top = 4;
        bottom = 4;
        left = 4;
        right = 4;
      };

      # Closest thing to niri's active/inactive border colors.
      decorations.inactive.dim = {
        opacity = -0.1;
      };

      swipe = {
        continuous = true;
        sensitivity = 0.6;
        scroll = {
          modifier = "alt";
          vertical_modifier = "shift";
        };
      };

      windows = {
        all = {
          title = ".*";
          # niri: default-column-width = 0.5
          width = 0.5;
          horizontal_padding = 4;
          vertical_padding = 4;
        };
        dialogs = {
          title = ".*";
          subrole = "AXDialog";
          floating = true;
        };
        system-settings = {
          title = ".*";
          bundle_id = "com.apple.systempreferences";
          floating = true;
        };
      };

      bindings = {
        # niri: focus-column-left/right, focus-window-down/up
        window_focus_west = "${modifier} - h";
        window_focus_south = "${modifier} - j";
        window_focus_north = "${modifier} - k";
        window_focus_east = "${modifier} - l";
        # niri: move-column-left/right, move-window-down/up
        window_swap_west = "${modifier} + shift - h";
        window_swap_south = "${modifier} + shift - j";
        window_swap_north = "${modifier} + shift - k";
        window_swap_east = "${modifier} + shift - l";

        # niri: focus-workspace-down/up, move-column-to-workspace-down/up
        window_virtual_south = "${modifier} - u";
        window_virtual_north = "${modifier} - i";
        window_virtualmove_south = "${modifier} + shift - u";
        window_virtualmove_north = "${modifier} + shift - i";

        # niri: focus-workspace N, move-column-to-workspace N
        window_virtualnum_1 = "${modifier} - 1";
        window_virtualnum_2 = "${modifier} - 2";
        window_virtualnum_3 = "${modifier} - 3";
        window_virtualnum_4 = "${modifier} - 4";
        window_virtualnum_5 = "${modifier} - 5";
        window_virtualmovenum_1 = "${modifier} + shift - 1";
        window_virtualmovenum_2 = "${modifier} + shift - 2";
        window_virtualmovenum_3 = "${modifier} + shift - 3";
        window_virtualmovenum_4 = "${modifier} + shift - 4";
        window_virtualmovenum_5 = "${modifier} + shift - 5";

        # niri: focus-monitor-*, move-column-to-monitor-*
        # paneru only knows "next display", so every direction maps to it.
        mouse_nextdisplay = map (key: "${modifier} + ctrl - ${key}") ["h" "j" "k" "l"];
        window_nextdisplay = map (key: "${modifier} + ctrl + shift - ${key}") ["h" "j" "k" "l"];

        # niri: consume-or-expel-window-left/right
        window_stack = "${modifier} - comma";
        window_unstack = "${modifier} - period";
        # niri: switch-preset-column-width (on e so cmd - r stays browser reload)
        window_resize = "${modifier} - e";
        # niri: maximize-window-to-edges / fullscreen-window
        window_fullwidth = ["${modifier} - m" "${modifier} + shift - f"];
        # niri: toggle-window-floating
        window_manage = "${modifier} + ctrl - space";

        # niri: quit (Mod+Shift+E). Stops paneru without launchd restarting it.
        quit = "${modifier} + shift - e";
      };
    };
  };
}
