{
  config,
  pkgs,
  inputs,
  ...
}: {
  home-manager.users.santi = {
    config,
    pkgs,
    ...
  }: {
    imports = [ ./common.nix ];
  };
}
