{
  config,
  pkgs,
  inputs,
  ...
}: {
  programs.neovim = {
    enable = true;
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
