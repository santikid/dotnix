{
  config,
  pkgs,
  inputs,
  ...
}: {
  home-manager.users.santi = {
    config,
    pkgs,
    ...
  }: {
    imports = [ ../shared/home ];
    home.file = {
      ".config/nvim" = {
        source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.nix/configs/nvim";
      };
    };
  };
}
