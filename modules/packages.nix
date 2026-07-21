{pkgs, ...}: {
  environment.systemPackages = [
    # Base tools
    pkgs.age
    pkgs.ncdu
    pkgs.jq
    pkgs.ripgrep
    pkgs.fzf
    pkgs.gh
    pkgs.nixd
    pkgs.pandoc
    pkgs.htop
    pkgs.btop
    pkgs.mosh

    # Development
    pkgs.python3
    pkgs.cmake
    pkgs.tree-sitter
    pkgs.nodejs_24
    pkgs.pnpm_11
    pkgs.bun
    pkgs.oxlint
    pkgs.prettier
    pkgs.svelte-language-server
    pkgs.typescript
    pkgs.typescript-language-server
    pkgs.vscode-langservers-extracted
    pkgs.rustc
    pkgs.cargo
    pkgs.rustfmt
    pkgs.clippy
    pkgs.rust-analyzer
    pkgs.pkg-config
    pkgs.bacon
    pkgs.lazygit

    # Media and backup
    pkgs.ffmpeg
    pkgs.imagemagick
    pkgs.borgbackup

    (pkgs.writeShellApplication {
      name = "ts";
      runtimeInputs =
        [
          pkgs.coreutils
          pkgs.findutils
          pkgs.fzf
          pkgs.tmux
        ]
        ++ pkgs.lib.optionals pkgs.stdenv.isLinux [
          pkgs.procps
        ];
      text = ''
        set +e
        set +o nounset

        if [[ $# -eq 1 ]]; then
          selected=$1
        else
          selected=$(find ~/Projects/co ~/Projects/p ~/Projects/w -mindepth 1 -maxdepth 1 -type d | fzf)
        fi

        if [[ -z $selected ]]; then
          exit 0
        fi

        selected_name=$(basename "$selected" | tr . _)
        tmux_running=$(pgrep tmux)

        if [[ -z $TMUX ]] && [[ -z $tmux_running ]]; then
          tmux new-session -s "$selected_name" -c "$selected"
          exit 0
        fi

        if ! tmux has-session -t="$selected_name" 2> /dev/null; then
          tmux new-session -ds "$selected_name" -c "$selected"
        fi

        if [[ -z $TMUX ]]; then
          tmux attach -t "$selected_name"
          exit 0
        fi

        tmux switch-client -t "$selected_name"
      '';
    })

    (pkgs.writeShellApplication {
      name = "hs";
      runtimeInputs = [
        pkgs.coreutils
        pkgs.findutils
        pkgs.fzf
        pkgs.herdr
        pkgs.jq
      ];
      text = ''
        selected=''${1:-$(find ~/Projects/co ~/Projects/p ~/Projects/w -mindepth 1 -maxdepth 1 -type d | fzf)} || exit 0
        [[ -n $selected ]] || exit 0

        cd "$selected"
        selected=$PWD
        selected_name=''${selected##*/}

        if ! workspaces=$(herdr workspace list 2>/dev/null); then
          nohup herdr server </dev/null >/dev/null 2>&1 &
          for ((attempt = 0; attempt < 50; attempt++)); do
            workspaces=$(herdr workspace list 2>/dev/null) && break
            sleep 0.1
          done
        fi

        workspace_id=$(
          jq -r --arg label "$selected_name" '
            .result.workspaces
            | map(select(.label == $label))
            | first
            | .workspace_id // empty
          ' <<<"$workspaces"
        )

        if [[ -n $workspace_id ]]; then
          herdr workspace focus "$workspace_id" >/dev/null
        else
          herdr workspace create --cwd "$selected" --label "$selected_name" --focus >/dev/null
        fi

        if [[ -z "''${HERDR_PANE_ID:-}" ]]; then
          exec herdr
        fi
      '';
    })
  ];
}
