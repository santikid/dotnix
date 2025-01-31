{
  config,
  pkgs,
  inputs,
  ...
}: {
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
}
