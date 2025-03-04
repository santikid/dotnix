{
  config,
  pkgs,
  inputs,
  user,
  ...
}: {
  programs.zsh.enable = true;
  environment.shells = [pkgs.zsh];
  environment.variables.EDITOR = "nvim";

  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';
}
