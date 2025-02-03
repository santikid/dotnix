{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  # Rust toolchain
  buildInputs = with pkgs; [
    rustc
    cargo

    rustfmt    
    clippy
    rust-analyzer
    
    pkg-config
    openssl
    zlib
    
    cargo-watch   # Rebuild on file changes
  ];
}
