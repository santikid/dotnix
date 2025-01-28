{pkgs, ...}:
with pkgs; [
  curl
  openssh

  pandoc

  wget
  watch
  zip

  ffmpeg

  fzf

  gh

  htop
  jq
  ripgrep
  tmux

  neovim

  imagemagick

  # js
  nodejs_22
  pnpm
  bun
]
