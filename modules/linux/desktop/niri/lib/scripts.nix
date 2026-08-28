{
  browserPackage,
  config,
  lib,
  pkgs,
  theme,
}: let
  inherit (theme) colors cursor;
  uiFont = theme.fonts.ui;

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

  commands = {
    browser = lib.getExe browserPackage;
    files = lib.getExe pkgs.nautilus;
    niri = lib.getExe config.programs.niri.package;
    noctalia = lib.getExe config.programs.noctalia.package;
    screenshot = lib.getExe screenshot;
    swayidle = lib.getExe pkgs.swayidle;
    tailscale = lib.getExe pkgs.tailscale;
    terminal = lib.getExe' pkgs.foot "foot";
    xwaylandSatellite = lib.getExe pkgs.xwayland-satellite;
  };
in {
  inherit
    commands
    cursor
    lockCommand
    ;
}
