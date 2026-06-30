{user, ...}: {
  home-manager.users.${user.name}.programs.zsh.shellAliases = {
    asahi = "sudo bless --mount /Volumes/NixOS --setBoot && sudo reboot";
  };
}
