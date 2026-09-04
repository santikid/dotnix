{pkgs, ...}: {
  programs.zsh.enable = true;
  environment.shells = [pkgs.zsh];
  environment.variables.EDITOR = "nvim";

  nix = {
    settings = {
      experimental-features = ["nix-command" "flakes"];
      extra-substituters = ["http://opal:8180/dotnix"];
      extra-trusted-public-keys = [
        "dotnix:N7VDgNbJ+yj6YV97+97s5HrxQ38+27OSPm17BexG3qA="
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
