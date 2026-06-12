{
  pkgs,
  user,
  ...
}: {
  home-manager.users.${user.name} = {config, ...}: {
    home.stateVersion = "24.05";

    home.sessionPath = [
      "$HOME/.local/bin"
    ];

    home.file.".config/nvim".source =
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.nix/configs/nvim";

    home.packages = [pkgs.neovim];

    programs.gpg.enable = true;
    services.gpg-agent = {
      enable = pkgs.stdenv.isLinux;
      enableScDaemon = true;
    };

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
      terminal = "xterm-ghostty";
      baseIndex = 1;
      clock24 = true;
      mouse = true;
      keyMode = "vi";
      customPaneNavigationAndResize = true;
      escapeTime = 0;
      historyLimit = 50000;
      extraConfig = ''
        set -g focus-events on
        set -g renumber-windows on

        # status bar
        set -g status-position bottom
        set -g status-style "bg=default,fg=#f8f8f2"
        set -g status-left " #[fg=#a9dc76,bold]#S #[default] "
        set -g status-right "#[fg=#727072]%H:%M "
        set -g status-left-length 30
        set -g status-right-length 20

        # windows
        set -g window-status-format "#[fg=#727072] #I #W "
        set -g window-status-current-format "#[fg=#f8f8f2,bold] #I #W "
        set -g window-status-separator ""

        # pane borders
        set -g pane-border-style "fg=#444444"
        set -g pane-active-border-style "fg=#a9dc76"

        # messages
        set -g message-style "bg=default,fg=#f8f8f2"
      '';
    };

    programs.eza = {
      enable = true;
      enableZshIntegration = true;
      icons = "auto";
      git = true;
    };

    programs.zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
      initContent = ''
        if [[ -n "''${SSH_CONNECTION:-}''${MOSH_IP:-}''${MOSH_CONNECTION:-}" ]]; then
          ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=0
          ZSH_HIGHLIGHT_MAXLENGTH=0
        fi

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

        zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
        zstyle ':completion:*' menu select
        zstyle ':completion:*' insert-unambiguous yes
        zstyle ':completion:*:descriptions' format '%F{green}-- %d --%f'

        [[ -f ~/.secrets.env ]] && source ~/.secrets.env
      '';
    };

    programs.starship.enable = true;
    programs.direnv.enable = true;
  };
}
