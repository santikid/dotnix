{
  config,
  pkgs,
  inputs,
  user,
  ...
}: {
  imports = [./secrets.nix];

  networking.nameservers = ["1.1.1.1" "1.0.0.1"];
  networking.networkmanager.dns = "none";

  security.polkit.enable = true;

  fonts.fontDir.enable = true;

  users.users.${user.name} = {
    isNormalUser = true;
    home = "/home/${user.name}";
    description = user.description;
    shell = pkgs.zsh;
    extraGroups = ["wheel" "video" "audio"];
    hashedPasswordFile = config.sops.secrets.user_pw.path;
  };
}
