{
  config,
  pkgs,
  inputs,
  user,
  ...
}: {
  environment.systemPackages = with pkgs;
    [
      gnupg
      age
      ncdu

      neovim
      lazygit

      cmake

      # Shell
      zsh
      starship

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

      # LSP
      svelte-language-server
      typescript-language-server
      typescript
      rust-analyzer
      vscode-langservers-extracted

      # Rust
      rustc
      cargo
      rustfmt
      clippy
      pkg-config

      # Terminal Utilities
      tmux
      htop
      btop

      # Media Processing
      ffmpeg
      imagemagick

      borgbackup
    ]
    ++ (import ./scripts.nix {inherit pkgs;});

  fonts.packages = with pkgs; [
    iosevka
  ];
}
