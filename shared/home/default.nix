{
  config,
  pkgs,
  inputs,
  ...
}: {
    home.stateVersion = "24.05";
    imports = [ 
      inputs.sops-nix.homeManagerModules.sops 
      ./shell
      ./neovim.nix
      ./gpg.nix
      ./secrets.nix
      ./env_secrets.nix
    ];
    
}
