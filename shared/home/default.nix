{
  config,
  pkgs,
  inputs,
  ...
}: {
    imports = [ ./shell.nix ./neovim.nix ];
}
