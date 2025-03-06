{
  config,
  pkgs,
  inputs,
  user,
  environment,
  ...
}: {
  home-manager.users.${user.name} = {
    imports = [
      inputs.sops-nix.homeManagerModules.sops
      ./env.nix
      ./config.nix
    ];
  };
}
