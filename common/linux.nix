{
  config,
  pkgs,
  inputs,
  ...
}: {
  programs.zsh.enable = true;

  environment.shells = [pkgs.zsh];

  environment.systemPackages = with pkgs; [
    docker
  ] ++ (import ../packages/system.nix {inherit pkgs;}) ++ (import ./scripts.nix {inherit pkgs;});

  fonts.fontDir.enable = true;
  fonts.packages = with pkgs; [] ++ (import ../packages/fonts.nix {inherit pkgs;});

  users.users.santi = {
    isNormalUser = true;
    home = "/home/santi";
    description = "Lukas Santner";
    shell = pkgs.zsh;
    extraGroups = [ "wheel" "docker" ];
  };

  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';
}
