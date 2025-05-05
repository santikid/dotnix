{
  config,
  pkgs,
  inputs,
  user,
  lib,
  ...
}: {
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
  programs.neovim = {
    enable = true;
    extraPackages = with pkgs; [
      ripgrep
      nixd
      prettierd
      stylua
      rustfmt
      lua-language-server
      tailwindcss-language-server
      typescript-language-server
      astro-language-server
      svelte-language-server
      rust-analyzer
    ];
  };
}
