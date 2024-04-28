{
  config,
  pkgs,
  inputs,
  ...
}: {
    home.stateVersion = "24.05";
    programs.git = {
      enable = true;
      userName = "Lukas Santner";
      userEmail = "lukas@santi.gg";
      signing = {
        key = "644E FF24 8A9C A2D2 69C3  0A7A 6AA8 09E3 B3CC CA64";
        signByDefault = true;
      };
      extraConfig = {
        init.defaultBranch = "main";
      };
    };

    programs.tmux = {
      enable = true;
      prefix = "C-a";
      baseIndex = 1;
      clock24 = true;
      mouse = true;
      keyMode = "vi";
      customPaneNavigationAndResize = true;
			terminal = "screen-256color";
			extraConfig = ''
set-option -sa terminal-features ',alacritty:RGB'
			'';
    };

    programs.starship.enable = true;
}
