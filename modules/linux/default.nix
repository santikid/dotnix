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
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILds3nmPYniDOxaeLUY6B7Om/nQF04wXpIqWaHwrkriA santi"
    ];
  };
}
