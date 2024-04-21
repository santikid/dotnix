{
  config,
  pkgs,
  inputs,
  ...
}: {
    home.stateVersion = "24.05";
    programs.git = {
      enable = true;
      userName = "Lukas Santner";
      userEmail = "lukas@santi.gg";
      signing = {
        key = "644E FF24 8A9C A2D2 69C3  0A7A 6AA8 09E3 B3CC CA64";
        signByDefault = true;
      };
    };
    programs.neovim = {
      enable = true;
      defaultEditor = true;
      vimdiffAlias = true;
    };

    programs.starship.enable = true;
    home.file = {
      ".config/nvim" = {
        source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.nix/configs/nvim";
      };
      ".config/alacritty/alacritty.toml" = {
        source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.nix/configs/alacritty.toml";
      };
    };
}
