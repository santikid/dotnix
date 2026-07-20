{
  pkgs,
  user,
  ...
}: {
  home-manager.users.${user.name} = {config, ...}: let
    emacsPackage =
      if pkgs.stdenv.isDarwin
      then pkgs.emacs
      else pkgs.emacs-nox;

    starshipPackage =
      if pkgs.stdenv.isDarwin
      then
        pkgs.starship.overrideAttrs (_: {
          # macOS 27's ld64 crashes in its stubs pass when linking Starship's
          # optional notification backend. Keep battery support and its tests.
          cargoBuildNoDefaultFeatures = "1";
          cargoBuildFeatures = "battery";
          cargoCheckNoDefaultFeatures = "1";
          cargoCheckFeatures = "battery";
        })
      else pkgs.starship;

    link = path:
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.nix/${path}";

    neovimPackage = pkgs.neovim;

    mkEditorLauncher = {
      name,
      terminalOnly ? false,
    }:
      pkgs.writeShellApplication {
        inherit name;
        runtimeInputs = [
          emacsPackage
          neovimPackage
        ];
        text =
          if terminalOnly
          then ''
            if emacsclient --eval t >/dev/null 2>&1; then
              exec emacsclient -t "$@"
            fi

            if command -v emacs >/dev/null 2>&1; then
              exec emacs -nw "$@"
            fi

            exec nvim "$@"
          ''
          else ''
            if emacsclient --eval t >/dev/null 2>&1; then
              if [[ -n "''${DISPLAY:-}''${WAYLAND_DISPLAY:-}" || "$(uname -s)" = "Darwin" ]]; then
                exec emacsclient -c -n "$@"
              fi

              exec emacsclient -t "$@"
            fi

            if command -v emacs >/dev/null 2>&1; then
              exec emacs "$@"
            fi

            exec nvim "$@"
          '';
      };
  in {
    home.stateVersion = "24.05";

    home.sessionPath = [
      "$HOME/.local/bin"
    ];

    home.file = {
      ".config/nvim".source = link "configs/nvim";
      ".emacs.d/init.el".source = link "configs/emacs/init.el";
      ".emacs.d/early-init.el".source = link "configs/emacs/early-init.el";
      ".emacs.d/config.org".source = link "configs/emacs/config.org";
    };

    home.packages = [
      neovimPackage
      emacsPackage
      (mkEditorLauncher {name = "e";})
      (mkEditorLauncher {
        name = "et";
        terminalOnly = true;
      })
    ];

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
      terminal = "tmux-256color";
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

        # Forward OSC 52 clipboard writes from remote or nested tmux sessions.
        set -s set-clipboard on
        set -as terminal-features ',foot:clipboard'
        set -as terminal-features ',tmux-256color:clipboard'
        set -as terminal-features ',screen-256color:clipboard'
        bind-key -T copy-mode-vi y send -X copy-selection-and-cancel

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

    programs.fzf = {
      enable = true;
      enableZshIntegration = true;
      defaultOptions = [
        "--height=40%"
        "--layout=reverse"
        "--border"
      ];
    };

    programs.zsh = {
      enable = true;
      enableCompletion = true;
      defaultKeymap = "viins";
      completionInit = ''
        # Use a compiled completion dump on normal startups. Refresh it (and
        # rerun compinit's security check) daily so new Nix completions appear.
        _cached_compinit() {
          setopt localoptions extendedglob
          local zcompdump="''${ZDOTDIR:-$HOME}/.zcompdump"

          if [[ ! -s "$zcompdump" || -n "$zcompdump"(#qN.mh+24) ]]; then
            compinit -d "$zcompdump"
          else
            compinit -C -d "$zcompdump"
          fi

          if [[ -s "$zcompdump" && (! -s "$zcompdump.zwc" || "$zcompdump" -nt "$zcompdump.zwc") ]]; then
            zcompile "$zcompdump"
          fi
        }

        autoload -Uz compinit
        _cached_compinit
        unfunction _cached_compinit
      '';
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
      history = {
        size = 100000;
        save = 100000;
        expireDuplicatesFirst = true;
        findNoDups = true;
        ignoreAllDups = true;
        ignoreDups = true;
        ignoreSpace = true;
        share = true;
      };
      initContent = ''
        # Zsh measures this in hundredths of a second. Its 0.4s default makes
        # Esc-prefixed bindings such as Esc-/ feel noticeably delayed.
        KEYTIMEOUT=5

        # command matching with up/downarrow
        autoload -U up-line-or-beginning-search
        autoload -U down-line-or-beginning-search
        zle -N up-line-or-beginning-search
        zle -N down-line-or-beginning-search
        bindkey "^[[A" up-line-or-beginning-search # Up
        bindkey "^[[B" down-line-or-beginning-search # Down
        bindkey "^[OA" up-line-or-beginning-search  # Up (application mode)
        bindkey "^[OB" down-line-or-beginning-search # Down (application mode)
        bindkey "^[[Z" reverse-menu-complete # Shift-Tab
        bindkey "^G" fzf-cd-widget # Ctrl-G: fuzzy directory picker
        bindkey -M vicmd "^G" fzf-cd-widget

        setopt AUTO_PUSHD PUSHD_IGNORE_DUPS PUSHD_SILENT
        alias d='dirs -v'
        for index ({1..9}) alias "$index"="cd +''${index}"; unset index

        zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
        zstyle ':completion:*' menu select
        zstyle ':completion:*' insert-unambiguous yes
        zstyle ':completion:*:descriptions' format '%F{green}-- %d --%f'

        [[ -f ~/.secrets.env ]] && source ~/.secrets.env
      '';
    };

    programs.starship = {
      enable = true;
      package = starshipPackage;
    };
    programs.direnv.enable = true;
  };
}
