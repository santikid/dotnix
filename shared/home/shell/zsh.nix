{ config, pkgs, ... }: {
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    # autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    initExtra = ''
    setopt AUTO_PUSHD PUSHD_IGNORE_DUPS PUSHD_SILENT
    alias d='dirs -v'
    for index ({1..9}) alias "$index"="cd +''${index}"; unset index
    '';
  };
  programs.starship = {
    enable = true;
  };
}