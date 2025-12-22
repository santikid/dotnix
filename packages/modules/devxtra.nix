{
  config,
  pkgs,
  inputs,
  user,
  lib,
  ...
}: {
  environment.systemPackages = with pkgs; [
    opencode
    claude-code
  ];
  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [
      "claude-code"
    ];
}
