{pkgs, ...}: {
  programs.zsh.enable = true;
  environment.shells = [pkgs.zsh];
  environment.variables.EDITOR = "nvim";

  nix.settings.experimental-features = ["nix-command" "flakes"];

  fonts.packages = [
    pkgs.inter
    pkgs.iosevka-bin
    pkgs.noto-fonts
    pkgs.noto-fonts-cjk-sans
    pkgs.noto-fonts-color-emoji
    pkgs.nerd-fonts.symbols-only
  ];
}
