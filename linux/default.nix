{
  config,
  pkgs,
  inputs,
  ...
}: {
  programs.zsh.enable = true;
  programs.hyprland.enable = true;

  security.polkit.enable = true;
  services.xserver = {
    enable = true;
    xkb.layout = "de";
    xkb.variant = "mac";
    autorun = true;
    displayManager.lightdm.enable = true;
  };

  environment.shells = [pkgs.zsh];

  environment.systemPackages = with pkgs; [
    gcc
    killall
    clang
    docker
    waybar
    alacritty
    dolphin
    firefox
    wofi
    nodejs
    hyprpaper
    chromium
  ] ++ (import ../shared/packages/global.nix {inherit pkgs;}) ++ (import ../shared/packages/vscode.nix {inherit pkgs;}) ++ (import ../shared/packages/scripts.nix {inherit pkgs;});


  environment.interactiveShellInit = ''
    alias rebuild='sudo nixos-rebuild switch --flake $HOME/.nix#santisasahi --impure'
  '';

  fonts.fontDir.enable = true;
  fonts.packages = with pkgs; [] ++ (import ../shared/packages/fonts.nix {inherit pkgs;});

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
