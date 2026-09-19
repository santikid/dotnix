{pkgs, ...}: {
  environment.systemPackages =
    if pkgs.stdenv.hostPlatform.isDarwin
    then [
      # Keep the language server matched to the active Xcode/Command Line Tools.
      (pkgs.writeShellScriptBin "sourcekit-lsp" ''
        exec /usr/bin/xcrun sourcekit-lsp "$@"
      '')
    ]
    else [
      pkgs.swift
      pkgs.swiftpm
      pkgs.sourcekit-lsp
    ];
}
