{
  pkgs,
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
    casks = ["ghostty"];
    brews = [
      "libvterm"
      "coreutils" # for emacs "gls"
    ];
  };

  networking = {
    dns = ["1.1.1.1" "1.0.0.1"];
    knownNetworkServices = ["Wi-Fi"];
  };

  security.pam.services.sudo_local.touchIdAuth = true;

  environment.etc."sudoers.d/darwin-rebuild".text = ''
    ${user.name} ALL=(ALL) NOPASSWD: /run/current-system/sw/bin/darwin-rebuild
  '';

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
}
