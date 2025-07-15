{
  config,
  pkgs,
  lib,
  inputs,
  user,
  ...
}: {
  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [
      "claude-code"
    ];
  environment.systemPackages = with pkgs; [
    claude-code
    gemini-cli
  ];
}
