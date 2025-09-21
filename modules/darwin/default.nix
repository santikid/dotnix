{
  config,
  pkgs,
  inputs,
  user,
  ...
}: {
  imports = [./system.nix];
  networking = {
    dns = ["1.1.1.1" "9.9.9.9"];
    knownNetworkServices = ["Wi-Fi"];
  };

  system.primaryUser = user.name;

  users.users.${user.name} = {
    description = user.description;
    home = "/Users/${user.name}";
    shell = pkgs.zsh;
  };

  homebrew = {
    enable = true;
    casks = pkgs.callPackage ./casks.nix {};
  };

  system.stateVersion = 5;
  security.pam.services.sudo_local.touchIdAuth = true;

  # Allow passwordless sudo for darwin-rebuild
  environment.etc."sudoers.d/darwin-rebuild".text = ''
    ${user.name} ALL=(ALL) NOPASSWD: /run/current-system/sw/bin/darwin-rebuild
  '';
}
