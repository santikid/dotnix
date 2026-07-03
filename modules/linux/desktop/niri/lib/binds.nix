{
  commands,
  lib,
  lockCommand,
}: let
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

  monitorBinds = mapBinds {
    "${modifier}+Ctrl+H" = {focus-monitor-left = [];};
    "${modifier}+Ctrl+J" = {focus-monitor-down = [];};
    "${modifier}+Ctrl+K" = {focus-monitor-up = [];};
    "${modifier}+Ctrl+L" = {focus-monitor-right = [];};
    "${modifier}+Ctrl+Shift+H" = {move-column-to-monitor-left = [];};
    "${modifier}+Ctrl+Shift+J" = {move-column-to-monitor-down = [];};
    "${modifier}+Ctrl+Shift+K" = {move-column-to-monitor-up = [];};
    "${modifier}+Ctrl+Shift+L" = {move-column-to-monitor-right = [];};
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

  applicationBinds =
    mapSpawnBinds {
      "${modifier}+Space" = [commands.fuzzel];
      "${modifier}+T" = [commands.terminal];
      "${modifier}+C" = [commands.browser];
      "${modifier}+F" = [commands.files];
      "${modifier}+Shift+V" = [commands.clipboardMenu];
      "${modifier}+Escape" = [commands.sessionMenu];
      "${modifier}+Ctrl+3" = [commands.screenshot "full"];
      "${modifier}+Ctrl+4" = [commands.screenshot "area"];
      "Alt+Print" = [commands.screenshot "area"];
    }
    // {
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
in {
  baseBinds = applicationBinds // directionalBinds // monitorBinds // actionBinds // parameterBinds // repeatlessBinds;
  inherit mediaBinds workspaceBinds;
}
