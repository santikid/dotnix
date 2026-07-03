{
  config,
  lib,
  pkgs,
  theme,
}: let
  inherit (theme) colors cursor icons;
  uiFont = theme.fonts.ui;

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
  hex = color: lib.removePrefix "#" color;
  withAlpha = color: alpha: "${hex color}${alpha}";

  lockCommand = lib.concatStringsSep " " [
    (lib.getExe pkgs.swaylock)
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
      battery=/sys/class/power_supply/macsmc-battery

      if [[ ! -r "$battery/capacity" ]]; then
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
in {
  inherit
    clipboardMenu
    colors
    commands
    cssSelector
    cursor
    hex
    icons
    lockCommand
    powerProfileMenu
    screenshot
    sessionMenu
    uiFont
    waybarBattery
    waybarModules
    waybarStyledSelectors
    withAlpha
    cliphistWatcher
    ;
}
