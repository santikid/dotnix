{
  config,
  pkgs,
  inputs,
  user,
  ...
}: {
  system.stateVersion = 5;

  users.users.${user.name} = {
    description = user.description;
    home = "/Users/${user.name}";
    shell = pkgs.zsh;
  };
  system.primaryUser = user.name;

  homebrew = {
    enable = true;
    casks = pkgs.callPackage ./casks.nix {};
    brews = pkgs.callPackage ./brews.nix {};
  };

  networking = {
    dns = ["1.1.1.1" "9.9.9.9"];
    knownNetworkServices = ["Wi-Fi"];
  };

  # TouchID for sudo
  security.pam.services.sudo_local.touchIdAuth = true;

  # Passwordless sudo for rebuilds
  environment.etc."sudoers.d/darwin-rebuild".text = ''
    ${user.name} ALL=(ALL) NOPASSWD: /run/current-system/sw/bin/darwin-rebuild
  '';

  system = {
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
        autohide-delay = 0.0;
        autohide-time-modifier = 0.0;
        show-recents = false;
        orientation = "bottom";
      };
      finder = {
        ShowPathbar = true;
        FXPreferredViewStyle = "clmv";
      };
    };
  };
}
