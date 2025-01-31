{
  config,
  pkgs,
  inputs,
  ...
}: {
  imports = [../shared/home];
  home.file = {
    ".config/nvim" = {
      source = config.lib.file.mkOutOfStoreSymlink "/.nix/configs/nvim";
    };
  };
}
