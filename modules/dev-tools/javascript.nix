{pkgs, ...}: {
  environment.systemPackages = [
    pkgs.nodejs_24
    pkgs.pnpm_11
    pkgs.bun
    pkgs.prettier
    pkgs.svelte-language-server
    pkgs.typescript
    pkgs.typescript-language-server
    pkgs.vscode-langservers-extracted
  ];
}
