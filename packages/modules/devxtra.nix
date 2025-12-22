{
  config,
  pkgs,
  inputs,
  user,
  lib,
  ...
}: {
  environment.systemPackages = with pkgs; [
  ];
}
