{
  config,
  pkgs,
  inputs,
  ...
}: {
  programs.zsh.enable = true;

  environment.shells = [pkgs.zsh];

  environment.systemPackages = with pkgs; [
    "fnm"
  ] ++ (import ../packages/system.nix {inherit pkgs;}) ++ (import ./scripts.nix {inherit pkgs;});

  environment.interactiveShellInit = ''
    alias rebuild='darwin-rebuild switch --flake ~/.nix#santibook'
    alias update='nix flake update ~/.nix && rebuild'
  '';

  fonts.fontDir.enable = true;
  fonts.fonts = with pkgs; [] ++ (import ../packages/fonts.nix {inherit pkgs;});

  users.users.santi = {
    description = "Lukas Santner";
    home = "/Users/santi";
    shell = pkgs.zsh;
  };

  services.nix-daemon.enable = true;

  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  homebrew = {
    enable = true;
    casks = pkgs.callPackage ../packages/brew/casks.nix {};
    brews = pkgs.callPackage ../packages/brew/formulae.nix {};
  };

  system.stateVersion = 4;

  system.defaults.NSGlobalDomain = {
    NSAutomaticCapitalizationEnabled = false;
    NSAutomaticPeriodSubstitutionEnabled = false;
    NSAutomaticSpellingCorrectionEnabled = false;

    InitialKeyRepeat = 15;
    KeyRepeat = 2;

    "com.apple.keyboard.fnState" = true;
  };

  system.defaults.dock = {
    autohide = true;
    autohide-delay = 0.0;
    autohide-time-modifier = 0.0;
    show-recents = false;
    orientation = "left";
    tilesize = 32;

    persistent-apps = [
      "/System/Applications/Mail.app"
      "/System/Cryptexes/App/System/Applications/Safari.app"
    ];
  };

  system.defaults.finder = {
    ShowPathbar = true;
    FXPreferredViewStyle = "clmv";
  };

  security.pam.enableSudoTouchIdAuth = true;
}
