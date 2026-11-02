{pkgs, ...}: {
  environment.systemPackages = [
    # Base tools
    pkgs.age
    pkgs.ncdu
    pkgs.jq
    pkgs.ripgrep
    pkgs.fzf
    pkgs.gh
    pkgs.forgejo-cli
    pkgs.pandoc
    pkgs.htop
    pkgs.btop
    pkgs.mosh
    pkgs.tuios

    # Media and backup
    pkgs.ffmpeg
    pkgs.imagemagick
    pkgs.borgbackup
    pkgs.rclone

    (pkgs.writeShellApplication {
      name = "ts";
      runtimeInputs = [
        pkgs.coreutils
        pkgs.findutils
        pkgs.fzf
        pkgs.jq
        pkgs.openssh
        pkgs.tuios
      ];
      text = ''
        # Pick a project here or on a linked tuios host and open its session.

        projects() {
          find ~/Projects/co ~/Projects/p ~/Projects/w -mindepth 1 -maxdepth 1 -type d 2> /dev/null || true
        }

        hosts_json() {
          tuios hosts --json 2> /dev/null || true
        }

        # Projects on every linked host, as host:/path.
        remote_projects() {
          hosts_json | jq -r '.hosts[]? | select(.status == "up") | "\(.host) \(.addr)"' |
            while read -r host addr; do
              ssh -n -o BatchMode=yes -o ConnectTimeout=5 "$addr" "$(declare -f projects); projects" |
                sed "s|^|$host:|" || true
            done
        }

        # Run tuios on the machine that holds the project.
        on_host() {
          if [[ -n $host ]]; then
            ssh -n -o BatchMode=yes "$addr" "tuios $(printf '%q ' "$@")"
          else
            tuios "$@"
          fi
        }

        if [[ $# -eq 1 ]]; then
          selected=$1
        else
          selected=$({ projects; remote_projects; } | fzf) || exit 0
        fi

        host=
        dir=$selected
        if [[ $selected =~ ^([^/:]+):(/.*)$ ]]; then
          host=''${BASH_REMATCH[1]}
          dir=''${BASH_REMATCH[2]}
          addr=$(hosts_json | jq -er --arg h "$host" '.hosts[]? | select(.host == $h) | .addr') ||
            { echo "ts: $host is not a tuios host" >&2; exit 1; }
        fi
        name=$(basename "$dir" | tr . _)

        # Create the session where the project lives (tuios refuses --cwd with --host);
        # this fails harmlessly when it already exists.
        on_host new "$name" -d --cwd "$dir" > /dev/null 2>&1 || true

        if [[ -n ''${TUIOS_ENV:-} ]]; then
          # A pane on a linked host may not move the client of the machine drawing it.
          tuios switch-session "''${host:+$host:}$name" 2> /dev/null ||
            echo "ts: $name is ready; open it with the session switcher (prefix s)"
        elif [[ -n $host ]]; then
          tuios attach --host "$host" "$name"
        else
          tuios attach "$name"
        fi
      '';
    })
  ];
}
