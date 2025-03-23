
{
  config,
  pkgs,
  inputs,
  user,
  ...
}: {
  programs.git = {
    enable = true;
    userName = user.description;
    userEmail = user.email;
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
