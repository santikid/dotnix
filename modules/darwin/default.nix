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

    background = 111318
    foreground = f4f7fb
    cursor-color = 7dd3fc
    selection-background = 2d3443
    selection-foreground = ffffff

    palette = 0=#111318
    palette = 1=#ff7b8a
    palette = 2=#a7f3d0
    palette = 3=#f6c177
    palette = 4=#7dd3fc
    palette = 5=#c4a7e7
    palette = 6=#67e8f9
    palette = 7=#e6edf3
    palette = 8=#667085
    palette = 9=#ff9aa6
    palette = 10=#c4f8df
    palette = 11=#ffd899
    palette = 12=#a5e4ff
    palette = 13=#d8b4fe
    palette = 14=#9bf6ff
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
