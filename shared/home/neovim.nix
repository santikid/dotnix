{
  config,
  pkgs,
  inputs,
  ...
}: {
    home.file = {
      ".config/nvim" = {
        source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.nix/configs/nvim";
      };
    };
    programs.neovim = {
        extraPackages = with pkgs; [
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
