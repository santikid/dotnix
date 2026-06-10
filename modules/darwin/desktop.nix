{pkgs, ...}: {
  homebrew.casks = [
    "secretive"
    "iina"
    "zen"
  ];

  environment.systemPackages = with pkgs; [
    lazygit

    # LSP
    svelte-language-server
    typescript-language-server
    typescript
    rust-analyzer
    vscode-langservers-extracted
  ];
}
