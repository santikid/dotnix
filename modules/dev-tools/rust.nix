{pkgs, ...}: {
  environment.systemPackages = [
    pkgs.rustc
    pkgs.cargo
    pkgs.rustfmt
    pkgs.clippy
    pkgs.rust-analyzer
    pkgs.bacon
  ];
}
