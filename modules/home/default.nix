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
      ./shell
      ./neovim.nix
      ./gpg.nix
    ];
  };
}
