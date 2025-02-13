{
  config,
  pkgs,
  inputs,
  user,
  ...
}: {
  home-manager.users.${user.name} = {
    imports = [./home.nix];
  };

  networking = {
    dns = ["1.1.1.1" "9.9.9.9"];
    knownNetworkServices = ["Wi-Fi"];
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

  fonts.packages = with pkgs; [] ++ (import ../shared/packages/fonts.nix {inherit pkgs;});

  users.users.${user.name} = {
    description = user.description;
    home = "/Users/${user.name}";
    shell = pkgs.zsh;
  };

  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  homebrew = {
    enable = true;
    casks = pkgs.callPackage ./packages/casks.nix {};
    brews = pkgs.callPackage ./packages/formulae.nix {};
  };

  system.stateVersion = 5;

  system = {
    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToControl = true;
    };
    defaults = {
      controlcenter = {
        BatteryShowPercentage = true;
        Sound = false;
        Bluetooth = false;
        AirDrop = false;
        Display = false;
        FocusModes = false;
        NowPlaying = false;
      };
      # Stage Manager - replaced with AeroSpace
      #WindowManager = {
      #  GloballyEnabled = true;
      #  AppWindowGroupingBehavior = false; # one at a time
      #};
      NSGlobalDomain = {
        NSAutomaticCapitalizationEnabled = false;
        NSAutomaticPeriodSubstitutionEnabled = false;
        NSAutomaticSpellingCorrectionEnabled = false;
        NSAutomaticDashSubstitutionEnabled = false;
        NSAutomaticQuoteSubstitutionEnabled = false;

        NSWindowShouldDragOnGesture = true;

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
  };

  security.pam.enableSudoTouchIdAuth = true;
}
