{pkgs, ...}: {
  environment.systemPackages = with pkgs;
    [
      age
      ncdu

      cmake

      # Development Tools
      jq
      ripgrep
      fzf
      gh

      # Text & Document Processing
      pandoc

      # Js
      nodejs_24
      pnpm
      bun

      # Rust
      rustc
      cargo
      rustfmt
      clippy
      pkg-config

      # Terminal Utilities
      htop
      btop

      # Media Processing
      ffmpeg
      imagemagick

      borgbackup
    ]
    ++ [
      (writeShellApplication {
        name = "ts";
        runtimeInputs = [tmux fzf];
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
          fi

          tmux switch-client -t "$selected_name"
        '';
      })
    ];

  fonts.packages = with pkgs; [
    iosevka
  ];
}
