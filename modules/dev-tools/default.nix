{pkgs, ...}: {
  imports = [
    ./javascript.nix
    ./python.nix
    ./rust.nix
  ];

  environment.systemPackages = [
    pkgs.cmake
    pkgs.tree-sitter
    pkgs.pkg-config
    pkgs.lazygit
    pkgs.nixd
  ];
}
