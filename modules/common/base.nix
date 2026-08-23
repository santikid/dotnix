{pkgs, ...}: {
  programs.zsh.enable = true;
  environment.shells = [pkgs.zsh];
  environment.variables.EDITOR = "nvim";

  nix = {
    settings = {
      experimental-features = ["nix-command" "flakes"];
      extra-substituters = ["http://obsidian:8180/dotnix"];
      extra-trusted-public-keys = [
        "dotnix:l60JA9kCmi7QH4e9UONJagnC7aqyJkJc++qsiKCYU6M="
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
