{
  browserPackage,
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

  networkMenu = pkgs.writeShellApplication {
    name = "network-menu";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.fuzzel
      pkgs.libnotify
      pkgs.networkmanager
      pkgs.networkmanagerapplet
    ];
    text = ''
      split_nmcli_line() {
        local input="$1"
        local character=""
        local field=""
        local escaped=0
        local index

        nmcli_fields=()
        for ((index = 0; index < ''${#input}; index++)); do
          character="''${input:index:1}"
          if (( escaped )); then
            field+="$character"
            escaped=0
          elif [[ "$character" == "\\" ]]; then
            escaped=1
          elif [[ "$character" == ':' ]]; then
            nmcli_fields+=("$field")
            field=""
          else
            field+="$character"
          fi
        done
        nmcli_fields+=("$field")
      }

      display_text() {
        local value="$1"
        value="''${value//$'\n'/ }"
        value="''${value//$'\r'/ }"
        value="''${value//$'\t'/ }"
        printf '%s' "$value"
      }

      signal_icon() {
        local signal="$1"

        if (( signal < 20 )); then
          printf '%s' '${builtins.elemAt icons.network.wifi 0}'
        elif (( signal < 40 )); then
          printf '%s' '${builtins.elemAt icons.network.wifi 1}'
        elif (( signal < 60 )); then
          printf '%s' '${builtins.elemAt icons.network.wifi 2}'
        elif (( signal < 80 )); then
          printf '%s' '${builtins.elemAt icons.network.wifi 3}'
        else
          printf '%s' '${builtins.elemAt icons.network.wifi 4}'
        fi
      }

      notify_error() {
        local message="$1"
        notify-send --app-name=network-menu --urgency=critical "Network connection failed" "$message"
      }

      notify_connected() {
        notify-send --app-name=network-menu "Connected" "$(display_text "$1")"
      }

      profile_uuid_for_ssid() {
        local ssid="$1"
        local index

        for index in "''${!saved_ssids[@]}"; do
          if [[ "''${saved_ssids[$index]}" == "$ssid" ]]; then
            printf '%s' "''${saved_uuids[$index]}"
            return 0
          fi
        done

        return 1
      }

      prompt_password() {
        local ssid="$1"

        fuzzel \
          --config=${fuzzelMenuConfig} \
          --dmenu \
          --prompt-only='Password  ' \
          --password \
          --mesg="Connect to $(display_text "$ssid")" \
          --width=36
      }

      connect_network() {
        local ssid="$1"
        local security="$2"
        local is_active="$3"
        local profile_uuid="$4"
        local output=""
        local password=""

        if (( is_active )); then
          notify-send --app-name=network-menu "Already connected" "$(display_text "$ssid")"
          return
        fi

        if [[ -n "$profile_uuid" ]]; then
          if output="$(nmcli --ask --wait 30 connection up uuid "$profile_uuid" </dev/null 2>&1)"; then
            notify_connected "$ssid"
            return
          fi
        fi

        if [[ -z "$security" || "$security" == "--" ]]; then
          if output="$(nmcli --ask --wait 30 device wifi connect "$ssid" </dev/null 2>&1)"; then
            notify_connected "$ssid"
          else
            notify_error "$output"
          fi
          return
        fi

        if [[ "$security" == *"802.1X"* || "$security" == *"EAP"* ]]; then
          notify-send \
            --app-name=network-menu \
            "Enterprise Wi-Fi requires advanced settings" \
            "Right-click the network icon to configure $(display_text "$ssid")"
          return
        fi

        password="$(prompt_password "$ssid")" || return 0
        [[ -n "$password" ]] || return

        if output="$(printf '%s\n' "$password" | nmcli --ask --wait 30 device wifi connect "$ssid" 2>&1)"; then
          notify_connected "$ssid"
        else
          notify_error "$output"
        fi
      }

      wifi_state="$(nmcli radio wifi 2>/dev/null || true)"
      if [[ "$wifi_state" != "enabled" && "$wifi_state" != "disabled" ]]; then
        notify_error "NetworkManager is unavailable"
        exit 1
      fi

      active_ssid=""
      declare -a saved_ssids=()
      declare -a saved_uuids=()
      declare -a ssids=()
      declare -a signals=()
      declare -a securities=()
      declare -a active=()
      declare -a profile_uuids=()

      while IFS= read -r line; do
        [[ -n "$line" ]] || continue
        split_nmcli_line "$line"
        (( ''${#nmcli_fields[@]} >= 3 )) || continue

        profile_uuid="''${nmcli_fields[1]}"
        profile_type="''${nmcli_fields[2]}"
        case "$profile_type" in
          wifi | 802-11-wireless) ;;
          *) continue ;;
        esac

        profile_ssid_line="$(
          nmcli \
            --terse \
            --escape yes \
            --get-values 802-11-wireless.ssid \
            connection show uuid "$profile_uuid" \
            2>/dev/null || true
        )"
        [[ -n "$profile_ssid_line" ]] || continue
        split_nmcli_line "$profile_ssid_line"
        (( ''${#nmcli_fields[@]} >= 1 )) || continue

        profile_ssid="''${nmcli_fields[0]}"
        [[ -n "$profile_ssid" ]] || continue
        saved_ssids+=("$profile_ssid")
        saved_uuids+=("$profile_uuid")
      done < <(nmcli --terse --escape yes --fields NAME,UUID,TYPE connection show 2>/dev/null)

      if [[ "$wifi_state" == "enabled" ]]; then
        while IFS= read -r line; do
          [[ -n "$line" ]] || continue
          split_nmcli_line "$line"
          (( ''${#nmcli_fields[@]} >= 4 )) || continue

          in_use="''${nmcli_fields[0]}"
          ssid="''${nmcli_fields[1]}"
          signal="''${nmcli_fields[2]}"
          security="''${nmcli_fields[3]}"
          [[ -n "$ssid" && "$signal" =~ ^[0-9]+$ ]] || continue
          profile_uuid="$(profile_uuid_for_ssid "$ssid" || true)"

          existing_index=-1
          for index in "''${!ssids[@]}"; do
            if [[ "''${ssids[$index]}" == "$ssid" ]]; then
              existing_index="$index"
              break
            fi
          done

          if (( existing_index >= 0 )); then
            if (( signal > signals[existing_index] )); then
              signals[existing_index]="$signal"
              securities[existing_index]="$security"
              profile_uuids[existing_index]="$profile_uuid"
            fi
            if [[ "$in_use" == "*" ]]; then
              active[existing_index]=1
              active_ssid="$ssid"
            fi
            continue
          fi

          ssids+=("$ssid")
          signals+=("$signal")
          securities+=("$security")
          profile_uuids+=("$profile_uuid")
          if [[ "$in_use" == "*" ]]; then
            active+=(1)
            active_ssid="$ssid"
          else
            active+=(0)
          fi
        done < <(nmcli --wait 15 --terse --escape yes --fields IN-USE,SSID,SIGNAL,SECURITY device wifi list --rescan auto 2>/dev/null)
      fi

      if [[ "$wifi_state" == "enabled" ]]; then
        toggle_label='󰖪   Turn Wi-Fi off'
        if [[ -n "$active_ssid" ]]; then
          menu_status="Wi-Fi  ·  $(display_text "$active_ssid")"
        elif (( ''${#ssids[@]} == 0 )); then
          menu_status='Wi-Fi  ·  No networks found'
        else
          menu_status='Wi-Fi  ·  Not connected'
        fi
      else
        toggle_label='${icons.network.disconnected}   Turn Wi-Fi on'
        menu_status='Wi-Fi  ·  Off'
      fi

      row_count=$((''${#ssids[@]} + 3))
      visible_lines="$row_count"
      (( visible_lines > 12 )) && visible_lines=12
      selected_index=0
      for index in "''${!active[@]}"; do
        if (( active[index] )); then
          selected_index=$((index + 2))
          break
        fi
      done

      choice="$(
        {
          printf '%s\n' "$toggle_label"
          printf '   Scan again\n'

          for index in "''${!ssids[@]}"; do
            ssid="$(display_text "''${ssids[$index]}")"
            security="''${securities[$index]}"
            signal="''${signals[$index]}"
            icon="$(signal_icon "$signal")"

            if [[ -n "$security" && "$security" != "--" ]]; then
              lock='  '
            else
              lock=""
            fi

            if (( active[index] )); then
              printf '✓  %s   %s%s  ·  %s%%\n' "$icon" "$ssid" "$lock" "$signal"
            else
              printf '   %s   %s%s  ·  %s%%\n' "$icon" "$ssid" "$lock" "$signal"
            fi
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
            --mesg="$menu_status" \
            --select-index="$selected_index" \
            --width=42 \
            --lines="$visible_lines"
      )" || exit 0
      [[ "$choice" =~ ^[0-9]+$ ]] || exit 0

      if (( choice == 0 )); then
        if [[ "$wifi_state" == "enabled" ]]; then
          if ! output="$(nmcli --ask radio wifi off </dev/null 2>&1)"; then
            notify_error "$output"
          fi
        else
          if output="$(nmcli --ask radio wifi on </dev/null 2>&1)"; then
            sleep 1
            exec "$0"
          else
            notify_error "$output"
          fi
        fi
      elif (( choice == 1 )); then
        if output="$(nmcli --ask --wait 15 device wifi rescan </dev/null 2>&1)"; then
          sleep 1
          exec "$0"
        else
          notify_error "$output"
        fi
      elif (( choice == ''${#ssids[@]} + 2 )); then
        exec nm-connection-editor
      else
        network_index=$((choice - 2))
        if (( network_index >= 0 && network_index < ''${#ssids[@]} )); then
          connect_network \
            "''${ssids[$network_index]}" \
            "''${securities[$network_index]}" \
            "''${active[$network_index]}" \
            "''${profile_uuids[$network_index]}"
        fi
      fi
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

      printf '{"text":"%s  %s%%","tooltip":"Battery %s%% · %s\\nClick: power modes","class":"%s"}\n' "$icon" "$capacity" "$capacity" "$status" "$class"
    '';
  };

  commands = {
    audioMenu = lib.getExe audioMenu;
    appLauncher = lib.getExe appLauncher;
    browser = lib.getExe browserPackage;
    brightnessctl = lib.getExe pkgs.brightnessctl;
    cliphist = lib.getExe pkgs.cliphist;
    clipboardMenu = lib.getExe clipboardMenu;
    files = lib.getExe pkgs.nautilus;
    mako = lib.getExe pkgs.mako;
    networkMenu = lib.getExe networkMenu;
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
    wlPaste = lib.getExe' pkgs.wl-clipboard "wl-paste";
    wpctl = lib.getExe' pkgs.wireplumber "wpctl";
    xwaylandSatellite = lib.getExe pkgs.xwayland-satellite;
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
    networkMenu
    powerProfileMenu
    screenshot
    sessionMenu
    uiFont
    waybarBattery
    waybarModules
    withAlpha
    cliphistWatcher
    ;
}
