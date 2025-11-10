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
    ]
    ++ (import ./scripts.nix {inherit pkgs;});

  fonts.packages = with pkgs; [
    iosevka
  ];
}
