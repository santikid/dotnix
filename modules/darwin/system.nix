{
  config,
  pkgs,
  inputs,
  user,
  ...
}: {
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
}
