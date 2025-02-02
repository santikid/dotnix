{
  config,
  pkgs,
  ...
}: {
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    initExtra = ''
      # command matching with up/downarrow
      autoload -U up-line-or-beginning-search
      autoload -U down-line-or-beginning-search
      zle -N up-line-or-beginning-search
      zle -N down-line-or-beginning-search
      bindkey "^[[A" up-line-or-beginning-search # Up
      bindkey "^[[B" down-line-or-beginning-search # Down

      setopt AUTO_PUSHD PUSHD_IGNORE_DUPS PUSHD_SILENT
      alias d='dirs -v'
      for index ({1..9}) alias "$index"="cd +''${index}"; unset index

      # Case-insensitive matching (so typing 'LS' can match 'ls')
      zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

      # Present a menu of possible completions when there's more than one match
      zstyle ':completion:*' menu select

      # Automatically insert any unambiguous prefix
      zstyle ':completion:*' insert-unambiguous yes

      # Show a slightly nicer description format (optional)
      zstyle ':completion:*:descriptions' format '%F{green}-- %d --%f'

    '';
  };
  programs.starship = {
    enable = true;
  };
}
