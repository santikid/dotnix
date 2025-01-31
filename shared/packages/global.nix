{pkgs, ...}:
with pkgs; [
  coreutils
  gnupg
  age
  git

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

  # Text & Document Processing
  pandoc

  # Terminal Utilities
  tmux
  htop
  btop # Added for system monitoring

  # Media Processing
  ffmpeg
  imagemagick

  # Editors
  neovim
]
