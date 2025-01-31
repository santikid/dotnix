{
  config,
  pkgs,
  inputs,
  ...
}: {
  home-manager.users.santi = {
    imports = [./home.nix];
  };

  programs.zsh.enable = true;

  environment.shells = [pkgs.zsh];

  environment.variables.EDITOR = "nvim";

  environment.systemPackages = with pkgs;
    [
    ]
    ++ (import ../shared/packages/global.nix {inherit pkgs;})
    ++ (import ../shared/packages/vscode.nix {inherit pkgs;})
    ++ (import ../shared/packages/scripts.nix {inherit pkgs;});

  environment.interactiveShellInit = ''
    alias rebuild='darwin-rebuild switch --flake ~/.nix#santibook'
    alias update='nix flake update --flake ~/.nix && rebuild'
  '';

  fonts.packages = with pkgs; [] ++ (import ../shared/packages/fonts.nix {inherit pkgs;});

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
    casks = pkgs.callPackage ./packages/casks.nix {};
    brews = pkgs.callPackage ./packages/formulae.nix {};
  };

  system.stateVersion = 4;

  system.defaults = {
    controlcenter = {
      BatteryShowPercentage = true;
      Sound = false;
      Bluetooth = false;
      AirDrop = false;
      Display = false;
      FocusModes = false;
      NowPlaying = false;
    };
    WindowManager = {
      GloballyEnabled = true;
      AppWindowGroupingBehavior = false; # one at a time
    };
    NSGlobalDomain = {
      NSAutomaticCapitalizationEnabled = false;
      NSAutomaticPeriodSubstitutionEnabled = false;
      NSAutomaticSpellingCorrectionEnabled = false;
      NSAutomaticDashSubstitutionEnabled = false;
      NSAutomaticQuoteSubstitutionEnabled = false;

      InitialKeyRepeat = 15;
      KeyRepeat = 2;

      "com.apple.keyboard.fnState" = true;
    };
    dock = {
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
    finder = {
      ShowPathbar = true;
      FXPreferredViewStyle = "clmv";
    };
  };

  security.pam.enableSudoTouchIdAuth = true;
}
