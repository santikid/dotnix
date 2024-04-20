{pkgs, ...}:
# called from both common/darwin.nix and common/linux.nix
with pkgs; [
  coreutils
  curl
  cmake
  gcc
  openssh
  pandoc
  sqlite
  wget
  zip

  gnupg
  libfido2

  ffmpeg
  neovim

  fnm
  fzf

  gh

  htop
  jq
  ripgrep
  tmux
  starship
]
