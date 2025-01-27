{pkgs, ...}:
# called from both common/darwin.nix and common/linux.nix
with pkgs; [
  curl
  openssh

  pandoc

  wget
  watch
  zip

  gnupg
  libfido2

  ffmpeg

  fzf

  gh

  htop
  jq
  ripgrep
  tmux

  neovim

  imagemagick
]
