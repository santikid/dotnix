{
  config,
  pkgs,
  inputs,
  ...
}: {
  programs.neovim.enable = true;
  home.sessionPath = [
    "$HOME/.local/bin"
  ];
  home.file = {
    ".config/nvim" =
      if pkgs.stdenv.isDarwin
      then {
        source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.nix/configs/nvim";
      }
      else {
        source = config.lib.file.mkOutOfStoreSymlink "/.nix/configs/nvim";
      };
  };
}
