{
  config,
  pkgs,
  inputs,
  ...
}: {
  imports = [./zsh.nix ./tools.nix];
}
