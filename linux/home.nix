{
  config,
  pkgs,
  inputs,
  ...
}: {
  imports = [../shared/home];
  home.file = {};
}
