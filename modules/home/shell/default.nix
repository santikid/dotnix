{
  config,
  pkgs,
  inputs,
  ...
}: {
  imports = [./tmux.nix ./git.nix ./zsh.nix];
}
