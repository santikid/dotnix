{
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [../shared/home];
  home.file = {
    ".config/nvim" = {
      source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.nix/configs/nvim";
    };
  };
}
