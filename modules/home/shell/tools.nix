{
  config,
  pkgs,
  inputs,
  user,
  ...
}: {
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = user.description;
        email = user.email;
      };
      init.defaultBranch = "main";
    };
  };
  programs.tmux = {
    enable = true;
    prefix = "C-a";
    # not sure how good this is
    terminal = "xterm-ghostty";
    baseIndex = 1;
    clock24 = true;
    mouse = true;
    keyMode = "vi";
    customPaneNavigationAndResize = true;
    extraConfig = ''
    '';
  };
  programs.eza = {
    enable = true;
    enableZshIntegration = true;
    icons = "auto";
    git = true;
  };
}
