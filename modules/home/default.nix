{
  config,
  pkgs,
  inputs,
  user,
  ...
}: {
  home-manager.users.${user.name} = {
    home.stateVersion = "24.05";
    imports = [
      inputs.sops-nix.homeManagerModules.sops
      ./shell
      ./neovim.nix
      ./gpg.nix
      ./secrets.nix
    ];
  };
}
