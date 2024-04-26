{pkgs, ...}:
# called from both common/darwin.nix and common/linux.nix
with pkgs; [
  coreutils
  curl
  cmake
  openssh
  pandoc
  sqlite
  wget
  watch
  zip

  gnupg
  libfido2

  ffmpeg
  neovim

#  fnm
  fzf

  gh

  htop
  jq
  ripgrep
  tmux
  starship

  imagemagick
]
