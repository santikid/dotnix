{
  config,
  pkgs,
  inputs,
  ...
}: {
  imports = [ ./secrets.nix ];
  
  programs.zsh.enable = true;

  security.polkit.enable = true;

  environment.shells = [pkgs.zsh];

  environment.systemPackages = with pkgs; [
    ghostty
  ] ++ (import ../shared/packages/global.nix {inherit pkgs;}) ++ 
    (import ../shared/packages/vscode.nix {inherit pkgs;}) ++ 
    (import ../shared/packages/scripts.nix {inherit pkgs;}) ++
    (import ../shared/packages/linux.nix {inherit pkgs;});

  fonts.fontDir.enable = true;
  fonts.packages = with pkgs; [] ++ (import ../shared/packages/fonts.nix {inherit pkgs;});

  users.users.santi = {
    isNormalUser = true;
    home = "/home/santi";
    description = "Lukas Santner";
    shell = pkgs.zsh;
    extraGroups = [ "wheel" "video" "audio" ];
    hashedPasswordFile = config.sops.secrets.pw_santi.path;
  };

  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';
}
