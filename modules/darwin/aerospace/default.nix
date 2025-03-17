{
  config,
  pkgs,
  inputs,
  user,
  ...
}: {
  # TODO: add resizing mode; vertical sketchybar on the right?
  services.aerospace = {
    enable = true;
    settings = {
      automatically-unhide-macos-hidden-apps = true;
      gaps = {
        inner.horizontal = 5;
        inner.vertical = 5;
        outer.left = 5;
        outer.bottom = 5;
        outer.top = 5;
        outer.right = 5;
      };
      workspace-to-monitor-force-assignment = {
        "1" = "secondary";
        "2" = "secondary";
        "3" = "secondary";
        "4" = "main";
        "5" = "main";
        "6" = "main";
      };
      mode.main.binding = {
        cmd-h = "focus left";
        cmd-j = "focus down";
        cmd-k = "focus up";
        cmd-l = "focus right";

        cmd-shift-h = "move left";
        cmd-shift-j = "move down";
        cmd-shift-k = "move up";
        cmd-shift-l = "move right";

        cmd-semicolon = "fullscreen";

        cmd-alt-m = "layout tiles horizontal vertical";
        cmd-alt-n = "layout accordion horizontal vertical";

        cmd-1 = "workspace 1";
        cmd-2 = "workspace 2";
        cmd-3 = "workspace 3";
        cmd-4 = "workspace 4";
        cmd-5 = "workspace 5";
        cmd-6 = "workspace 6";
        cmd-shift-1 = "move-node-to-workspace 1";
        cmd-shift-2 = "move-node-to-workspace 2";
        cmd-shift-3 = "move-node-to-workspace 3";
        cmd-shift-4 = "move-node-to-workspace 4";
        cmd-shift-5 = "move-node-to-workspace 5";
        cmd-shift-6 = "move-node-to-workspace 6";
      };
    };
  };
}
