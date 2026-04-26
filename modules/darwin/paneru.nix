{
  pkgs,
  user,
  inputs,
  ...
}: {
  home-manager.users.${user.name} = {config, ...}: {
    imports = [
      inputs.paneru.homeModules.paneru
    ];

    services.paneru = {
      enable = true;
      settings = {
        options = {
          focus_follows_mouse = true;
          mouse_follows_focus = true;
        };
        swipe = {
          continuous = true;
          gesture.fingers_count = 3;
        };
        bindings = {
          window_focus_west = "cmd - h";
          window_focus_east = "cmd - l";
          window_focus_north = "cmd - k";
          window_focus_south = "cmd - j";
          window_swap_west = "cmd + shift - h";
          window_swap_east = "cmd + shift - l";

          window_center = "alt - c";
          window_resize = "alt - r";
          window_fullwidth = "alt - f";
          window_manage = "alt + shift - t";

          window_virtual_north = "alt - k";
          window_virtual_south = "alt - j";
          window_virtualmove_north = "alt + shift - k";
          window_virtualmove_south = "alt + shift - j";
        };
      };
    };
  };
}
