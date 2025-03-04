{
  config,
  pkgs,
  inputs,
  ...
}: {
  imports = [./tmux.nix ./git.nix ./zsh.nix ./env_secrets.nix];
}
