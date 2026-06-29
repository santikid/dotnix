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

  home-manager.users.${user.name}.home.file."Library/Application Support/com.mitchellh.ghostty/config".text = ''
    font-family = Iosevka
    font-size = 12
    window-padding-x = 12
    window-padding-y = 10

    background = 111111
    foreground = eeeeee
    cursor-color = eeeeee
    selection-background = 3a3a3a
    selection-foreground = ffffff

    palette = 0=#111111
    palette = 1=#d16d6d
    palette = 2=#8fa876
    palette = 3=#d6b25e
    palette = 4=#b8b8b8
    palette = 5=#c49ab7
    palette = 6=#9bb0ad
    palette = 7=#e8e8e8
    palette = 8=#5a5a5a
    palette = 9=#e08a8a
    palette = 10=#a8be8f
    palette = 11=#e0c279
    palette = 12=#d0d0d0
    palette = 13=#d5b0ca
    palette = 14=#b7c7c4
    palette = 15=#ffffff
  '';

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
