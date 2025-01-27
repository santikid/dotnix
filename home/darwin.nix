
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
    imports = [ ./common.nix ];
    home.file = {
      ".config/nvim" = {
        source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.nix/configs/nvim";
      };
    };
    programs.zsh = {
      enable = true;
      initExtra = ''
autoload -U compinit; compinit
_comp_options+=(globdots) # With hidden files

setopt AUTO_PUSHD           # Push the current directory visited on the stack.
setopt PUSHD_IGNORE_DUPS    # Do not store duplicates in the stack.
setopt PUSHD_SILENT         # Do not print the directory stack after pushd or popd.

zstyle ':completion:*' list-colors "$${(s.:.)LS_COLORS}"
#zstyle ':completion:*' file-sort modification
zstyle ':completion:*' file-sort date
zstyle ':completion:*' menu yes=long select

bindkey -v
autoload -U up-line-or-beginning-search
autoload -U down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey "^[[A" up-line-or-beginning-search # Up
bindkey "^[[B" down-line-or-beginning-search # Down
bindkey '^R' history-incremental-search-backward
      '';
    };
  };
}
