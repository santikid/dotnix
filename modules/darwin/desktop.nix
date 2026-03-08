{pkgs, ...}: {
  homebrew.casks = [
    "linearmouse"
    "secretive"
    "iina"
    "zen"
    "google-chrome"
    "ungoogled-chromium"
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
