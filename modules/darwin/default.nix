{
  lib,
  pkgs,
  user,
  ...
}: let
  ghosttyFont = "Iosevka";
  ghosttyTheme = {
    palette = [
      "0=#111318"
      "1=#ff7b8a"
      "2=#a7f3d0"
      "3=#f6c177"
      "4=#7dd3fc"
      "5=#c4a7e7"
      "6=#67e8f9"
      "7=#e6edf3"
      "8=#667085"
      "9=#ff9aa6"
      "10=#c4f8df"
      "11=#ffd899"
      "12=#a5e4ff"
      "13=#d8b4fe"
      "14=#9bf6ff"
      "15=#ffffff"
    ];
    background = "111318";
    foreground = "f4f7fb";
    cursor-color = "7dd3fc";
    selection-background = "2d3443";
    selection-foreground = "ffffff";
  };
  paletteLines = map (entry: "palette = ${entry}") ghosttyTheme.palette;
in {
  users.users.${user.name} = {
    description = user.description;
    home = "/Users/${user.name}";
    shell = pkgs.zsh;
  };

  system.primaryUser = user.name;
  system.stateVersion = 5;

  homebrew = {
    enable = true;
    casks = ["ghostty"];
    brews = [
      "libvterm"
      "coreutils" # for emacs "gls"
    ];
  };

  home-manager.users.${user.name}.home.file."Library/Application Support/com.mitchellh.ghostty/config".text = lib.concatStringsSep "\n" ([
      "font-family = ${ghosttyFont}"
      "font-size = 16"
      ""
      "background = ${ghosttyTheme.background}"
      "foreground = ${ghosttyTheme.foreground}"
      "cursor-color = ${ghosttyTheme."cursor-color"}"
      "selection-background = ${ghosttyTheme."selection-background"}"
      "selection-foreground = ${ghosttyTheme."selection-foreground"}"
      ""
    ]
    ++ paletteLines
    ++ [""]);

  networking = {
    dns = ["1.1.1.1" "1.0.0.1"];
    knownNetworkServices = lib.mkDefault ["Wi-Fi"];
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
