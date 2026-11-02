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
      runtimeInputs =
        [
          pkgs.coreutils
          pkgs.findutils
          pkgs.fzf
          pkgs.jq
          pkgs.openssh
          pkgs.tuios
        ];
      text = ''
        set +e
        set +o nounset

        list_projects() {
          find ~/Projects/co ~/Projects/p ~/Projects/w -mindepth 1 -maxdepth 1 -type d 2> /dev/null
        }

        # Projects on every linked tuios host, as host:/path.
        list_remote_projects() {
          tuios hosts --json 2> /dev/null |
            jq -r '.hosts[]? | select(.status == "up") | "\(.host) \(.addr)"' |
            while read -r host addr; do
              ssh -n -o BatchMode=yes -o ConnectTimeout=5 "$addr" \
                'find ~/Projects/co ~/Projects/p ~/Projects/w -mindepth 1 -maxdepth 1 -type d 2> /dev/null' |
                sed "s|^|$host:|"
            done
        }

        if [[ $# -eq 1 ]]; then
          selected=$1
        else
          selected=$({ list_projects; list_remote_projects; } | fzf)
        fi

        if [[ -z $selected ]]; then
          exit 0
        fi

        host=
        dir=$selected
        if [[ $selected =~ ^([^/:]+):(/.*)$ ]]; then
          host=''${BASH_REMATCH[1]}
          dir=''${BASH_REMATCH[2]}
        fi

        selected_name=$(basename "$dir" | tr . _)

        # Inside tuios, switch this client in place instead of nesting.
        if [[ -n $TUIOS_ENV ]]; then
          tuios switch-session --create --cwd "$dir" "''${host:+$host:}$selected_name"
          exit 0
        fi

        # tuios starts the daemon on demand; ls lists saved sessions when it is down.
        if [[ -n $host ]]; then
          host_args=(--host "$host")
          sessions='.hosts[]?.sessions[]?'
        else
          host_args=()
          sessions='.[]'
        fi

        if tuios ls "''${host_args[@]}" --json 2> /dev/null |
          jq -e --arg n "$selected_name" "any($sessions; .name == \$n)" > /dev/null; then
          tuios attach "''${host_args[@]}" "$selected_name"
        else
          tuios new "''${host_args[@]}" "$selected_name" --cwd "$dir"
        fi
      '';
    })
  ];
}
