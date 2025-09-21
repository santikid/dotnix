{
  config,
  pkgs,
  inputs,
  user,
  ...
}: {
  environment.systemPackages = with pkgs;
    [
      coreutils
      gnumake
      gnupg
      age
      git
      ncdu
      fd

      tectonic
      ghostscript
      mermaid-cli

      lazygit

      # Networking & Download Tools
      curl
      wget

      # Archiving & File Management
      zip
      watch

      # Shell
      zsh
      starship

      # Development Tools
      gcc
      clang
      jq
      ripgrep
      fzf
      gh
      nodejs_22
      pnpm
      bun
      #postgresql_16

      # Text & Document Processing
      pandoc

      # Terminal Utilities
      tmux
      htop
      btop # Added for system monitoring

      # Media Processing
      ffmpeg
      imagemagick
    ]
    ++ (import ./scripts.nix {inherit pkgs;});

  fonts.packages = with pkgs; [
    iosevka
  ];
}
