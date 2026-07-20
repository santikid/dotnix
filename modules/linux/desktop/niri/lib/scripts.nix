{
  config,
  lib,
  pkgs,
  theme,
}: let
  inherit (theme) colors cursor icons;
  uiFont = theme.fonts.ui;

  waybarModules = {
    left = ["niri/workspaces"];
    center = [];
    right = [
      "group/status"
      "group/controls"
      "group/clock"
    ];
  };

  hex = color: lib.removePrefix "#" color;
  withAlpha = color: alpha: "${hex color}${alpha}";

  fuzzelMenuConfig = pkgs.writeText "fuzzel-menu.ini" ''
    font=${uiFont}:size=12,Symbols Nerd Font Mono:size=12
    use-bold=yes
    tabs=4
    horizontal-pad=20
    vertical-pad=14
    inner-pad=10
    line-height=20
    anchor=top-right
    x-margin=32
    y-margin=0
    layer=overlay
    keyboard-focus=on-demand
    icons-enabled=no
    image-size-ratio=1
    match-mode=fzf
    cache=/dev/null

    [colors]
    background=${withAlpha colors.bar "fd"}
    text=${withAlpha colors.text "ff"}
    message=${withAlpha colors.muted "ff"}
    prompt=${withAlpha colors.muted "ff"}
    placeholder=${withAlpha colors.dim "ff"}
    input=${withAlpha colors.text "ff"}
    match=${withAlpha colors.accent "ff"}
    selection=${withAlpha colors.surfaceHover "ff"}
    selection-text=${withAlpha colors.text "ff"}
    selection-match=${withAlpha colors.accent "ff"}
    counter=${withAlpha colors.dim "ff"}
    border=${withAlpha colors.barBorder "ff"}

    [border]
    width=1
    radius=10
    selection-radius=5
  '';

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

  appLauncher = pkgs.writeShellApplication {
    name = "app-launcher";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.fuzzel
    ];
    text = ''
      runtime_dir="''${XDG_RUNTIME_DIR:-}"
      [[ -n "$runtime_dir" && -d "$runtime_dir" ]] || exit 1
      pid_file="$runtime_dir/fuzzel-app-launcher.pid"

      if [[ -r "$pid_file" ]]; then
        launcher_pid=""
        read -r launcher_pid < "$pid_file" || true
        if [[ "$launcher_pid" =~ ^[0-9]+$ ]] \
          && [[ -r "/proc/$launcher_pid/comm" ]] \
          && [[ "$(<"/proc/$launcher_pid/comm")" == fuzzel ]]; then
          kill "$launcher_pid"
          exit 0
        fi
        rm -f "$pid_file"
      fi

      launcher_pid=""
      cleanup() {
        current_pid=""
        if [[ -r "$pid_file" ]]; then
          read -r current_pid < "$pid_file" || true
          [[ "$current_pid" == "$launcher_pid" ]] && rm -f "$pid_file"
        fi
      }
      trap cleanup EXIT

      fuzzel &
      launcher_pid=$!
      printf '%s\n' "$launcher_pid" > "$pid_file"
      wait "$launcher_pid" || true
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
      choice="$(
        cliphist list |
          fuzzel \
            --config=${fuzzelMenuConfig} \
            --dmenu \
            --prompt 'Clipboard  ' \
            --placeholder 'Search history…' \
            --width=56 \
            --lines=9
      )" || exit 0
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
        printf '   Lock screen\n   Sleep\n   Log out\n   Restart\n   Shut down\n' |
          fuzzel \
            --config=${fuzzelMenuConfig} \
            --dmenu \
            --index \
            --no-sort \
            --minimal-lines \
            --only-match \
            --hide-prompt \
            --mesg='Session' \
            --width=26 \
            --lines=5
      )" || exit 0

      case "$choice" in
        0)
          ${lockCommand}
          ;;
        1)
          systemctl suspend
          ;;
        2)
          niri msg action quit
          ;;
        3)
          systemctl reboot
          ;;
        4)
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

      case "$current" in
        power-saver)
          current_label='Power saver'
          selected=0
          ;;
        performance)
          current_label='Performance'
          selected=2
          ;;
        balanced)
          current_label='Balanced'
          selected=1
          ;;
        *)
          current_label='Unavailable'
          selected=1
          ;;
      esac

      choice="$(
        printf '   Power saver\n   Balanced\n   Performance\n' |
          fuzzel \
            --config=${fuzzelMenuConfig} \
            --dmenu \
            --index \
            --no-sort \
            --minimal-lines \
            --only-match \
            --hide-prompt \
            --mesg="Power  ·  $current_label" \
            --select-index="$selected" \
            --width=30 \
            --lines=3
      )" || exit 0

      case "$choice" in
        0) powerprofilesctl set power-saver ;;
        1) powerprofilesctl set balanced ;;
        2) powerprofilesctl set performance ;;
      esac
    '';
  };

  audioMenu = pkgs.writeShellApplication {
    name = "audio-menu";
    runtimeInputs = [
      pkgs.fuzzel
      pkgs.jq
      pkgs.pavucontrol
      pkgs.pulseaudio
      pkgs.wireplumber
    ];
    text = ''
      volume_line="$(wpctl get-volume @DEFAULT_AUDIO_SINK@ 2>/dev/null || true)"
      if [[ "$volume_line" =~ ^Volume:\ ([0-9.]+) ]]; then
        volume_scalar="''${BASH_REMATCH[1]}"
      else
        volume_scalar=0
      fi
      volume_percent="$(jq -nr --arg value "$volume_scalar" '$value | tonumber * 100 | round')"

      if [[ "$volume_line" == *'[MUTED]'* ]]; then
        volume_status="Muted · $volume_percent%"
        mute_label='   Unmute'
      else
        volume_status="$volume_percent%"
        mute_label='󰍟   Mute'
      fi

      default_sink="$(pactl get-default-sink 2>/dev/null || true)"
      sink_data="$(pactl --format=json list sinks 2>/dev/null || printf '[]')"
      mapfile -t sink_names < <(jq -r '.[].name' <<<"$sink_data")
      mapfile -t sink_descriptions < <(jq -r '.[].description' <<<"$sink_data")
      sink_count="''${#sink_names[@]}"

      selected=0
      for index in "''${!sink_names[@]}"; do
        if [[ "''${sink_names[$index]}" == "$default_sink" ]]; then
          selected=$((index + 3))
          break
        fi
      done

      row_count=$((sink_count + 4))
      choice="$(
        {
          printf '   Volume +5%%\n'
          printf '   Volume −5%%\n'
          printf '%s\n' "$mute_label"

          for index in "''${!sink_names[@]}"; do
            description="''${sink_descriptions[$index]}"
            if [[ "''${sink_names[$index]}" == "$default_sink" ]]; then
              description="✓ $description"
            fi
            printf '   %s\n' "$description"
          done

          printf '   Advanced settings\n'
        } |
          fuzzel \
            --config=${fuzzelMenuConfig} \
            --dmenu \
            --index \
            --no-sort \
            --minimal-lines \
            --only-match \
            --hide-prompt \
            --mesg="Audio  ·  $volume_status" \
            --select-index="$selected" \
            --width=40 \
            --lines="$row_count"
      )" || exit 0

      case "$choice" in
        0)
          wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.05+ -l 1.0
          ;;
        1)
          wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.05-
          ;;
        2)
          wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
          ;;
        *)
          advanced_index=$((sink_count + 3))
          if (( choice == advanced_index )); then
            exec pavucontrol
          fi

          sink_index=$((choice - 3))
          if (( sink_index >= 0 && sink_index < sink_count )); then
            sink_name="''${sink_names[$sink_index]}"
            pactl set-default-sink "$sink_name"
            while read -r input_id _; do
              pactl move-sink-input "$input_id" "$sink_name" || true
            done < <(pactl list short sink-inputs)
          fi
          ;;
      esac
    '';
  };

  waybarPowerProfile = pkgs.writeShellApplication {
    name = "waybar-power-profile";
    runtimeInputs = [pkgs.power-profiles-daemon];
    text = ''
      profile="$(powerprofilesctl get 2>/dev/null || true)"

      case "$profile" in
        power-saver)
          icon='${icons.power.saver}'
          tooltip='Power saver · Longer battery life'
          class='power-saver'
          ;;
        balanced)
          icon='${icons.power.balanced}'
          tooltip='Balanced power mode'
          class='balanced'
          ;;
        performance)
          icon='${icons.power.performance}'
          tooltip='Performance mode · Higher energy use'
          class='performance'
          ;;
        *)
          icon='${icons.power.unknown}'
          tooltip='Power mode unavailable'
          class='unknown'
          ;;
      esac

      printf '{"text":"%s","tooltip":"%s","class":"%s"}\n' "$icon" "$tooltip" "$class"
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
        icon="${icons.charging}"
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

      printf '{"text":"%s  %s%%","tooltip":"Battery %s%% · %s","class":"%s"}\n' "$icon" "$capacity" "$capacity" "$status" "$class"
    '';
  };

  commands = {
    audioMenu = lib.getExe audioMenu;
    appLauncher = lib.getExe appLauncher;
    browser = lib.getExe pkgs.firefox;
    brightnessctl = lib.getExe pkgs.brightnessctl;
    cliphist = lib.getExe pkgs.cliphist;
    clipboardMenu = lib.getExe clipboardMenu;
    files = lib.getExe pkgs.nautilus;
    mako = lib.getExe pkgs.mako;
    niri = lib.getExe config.programs.niri.package;
    pavucontrol = lib.getExe pkgs.pavucontrol;
    playerctl = lib.getExe pkgs.playerctl;
    powerProfileMenu = lib.getExe powerProfileMenu;
    screenshot = lib.getExe screenshot;
    sessionMenu = lib.getExe sessionMenu;
    swayidle = lib.getExe pkgs.swayidle;
    tailscale = lib.getExe pkgs.tailscale;
    terminal = lib.getExe' pkgs.foot "foot";
    waybar = lib.getExe pkgs.waybar;
    waybarBattery = lib.getExe waybarBattery;
    waybarPowerProfile = lib.getExe waybarPowerProfile;
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
    audioMenu
    appLauncher
    clipboardMenu
    colors
    commands
    cursor
    hex
    icons
    lockCommand
    powerProfileMenu
    screenshot
    sessionMenu
    uiFont
    waybarBattery
    waybarPowerProfile
    waybarModules
    withAlpha
    cliphistWatcher
    ;
}
