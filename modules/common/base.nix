{pkgs, ...}: {
  programs.zsh.enable = true;
  environment.shells = [pkgs.zsh];
  environment.variables.EDITOR = "nvim";

  nix = {
    settings = {
      experimental-features = ["nix-command" "flakes"];
      extra-substituters = ["http://obsidian:8180/dotnix"];
      extra-trusted-public-keys = [
        "dotnix:JTkDCW+G8IHsYFIX1dZrZPY1wmZYGiqLEOKhnKxYFdI="
      ];
    };

    gc = {
      automatic = true;
      options = "--delete-older-than 30d";
    };

    optimise.automatic = true;
  };

  fonts.packages = [
    pkgs.inter
    pkgs.iosevka-bin
    pkgs.noto-fonts
    pkgs.noto-fonts-cjk-sans
    pkgs.noto-fonts-color-emoji
    pkgs.nerd-fonts.symbols-only
  ];
}
