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

    programs.neovim.enable = true;

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
      # not sure how good this is
      terminal = "xterm-ghostty";
      baseIndex = 1;
      clock24 = true;
      mouse = true;
      keyMode = "vi";
      customPaneNavigationAndResize = true;
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
      '';
    };

    programs.starship.enable = true;
    programs.direnv.enable = true;
  };
}
