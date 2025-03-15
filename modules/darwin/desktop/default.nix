{
  config,
  pkgs,
  inputs,
  ...
}: {
  homebrew = {
    enable = true;
    casks = pkgs.callPackage ./casks.nix {};
  };
  system.defaults.dock.autohide = true;
}
