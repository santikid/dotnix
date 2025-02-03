{
  config,
  pkgs,
  inputs,
  user,
  ...
}: {
  imports = [./secrets.nix];

  home-manager.users.${user.name} = {
    imports = [./home.nix];
  };

  networking.nameservers = ["1.1.1.1" "1.0.0.1"];
  networking.networkmanager.dns = "none";

  programs.zsh.enable = true;

  security.polkit.enable = true;

  environment.shells = [pkgs.zsh];

  environment.systemPackages = with pkgs;
    [
      ghostty
    ]
    ++ (import ../shared/packages/global.nix {inherit pkgs;})
    ++ (import ../shared/packages/scripts.nix {inherit pkgs;})
    ++ (import ./packages.nix {inherit pkgs;});

  fonts.fontDir.enable = true;
  fonts.packages = with pkgs; [] ++ (import ../shared/packages/fonts.nix {inherit pkgs;});

  users.users.${user.name} = {
    isNormalUser = true;
    home = "/home/${user.name}";
    description = user.description;
    shell = pkgs.zsh;
    extraGroups = ["wheel" "video" "audio"];
    hashedPasswordFile = config.sops.secrets.user_pw.path;
  };

  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';
}
