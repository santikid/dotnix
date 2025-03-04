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
}
