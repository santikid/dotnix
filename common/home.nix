{
  config,
  pkgs,
  inputs,
  ...
}: {
  home-manager.users.santi = {
    config,
    pkgs,
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
    };
    programs.neovim = {
      enable = true;
      defaultEditor = true;
      vimdiffAlias = true;
    };
    programs.zsh = {
      enable = true;
      initExtra = ''
        autoload -U compinit; compinit
        _comp_options+=(globdots) # With hidden files

        setopt AUTO_PUSHD           # Push the current directory visited on the stack.
        setopt PUSHD_IGNORE_DUPS    # Do not store duplicates in the stack.
        setopt PUSHD_SILENT         # Do not print the directory stack after pushd or popd.

        zstyle ':completion:*' file-sort date
        zstyle ':completion:*' menu yes=long select

        bindkey -v
        autoload -U up-line-or-beginning-search
        autoload -U down-line-or-beginning-search
        zle -N up-line-or-beginning-search
        zle -N down-line-or-beginning-search
        bindkey "^[[A" up-line-or-beginning-search # Up
        bindkey "^[[B" down-line-or-beginning-search # Down

        eval "$(/opt/homebrew/bin/brew shellenv)"
        eval "$(fnm env)"
        . "$HOME/.cargo/env"
      '';
    };
    programs.starship.enable = true;
    home.file = {
      ".config/nvim" = {
        source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.nix/configs/nvim";
      };
      ".config/alacritty/alacritty.toml" = {
        source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.nix/configs/alacritty.toml";
      };
    };
  };
}
