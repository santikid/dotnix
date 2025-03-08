{
  config,
  pkgs,
  inputs,
  user,
  ...
}: {
  environment.systemPackages = with pkgs;
    [
      coreutils
      gnumake
      gnupg
      age
      git
      ncdu

      # Networking & Download Tools
      curl
      wget

      # Archiving & File Management
      zip
      watch

      # Shell
      zsh
      starship

      # Development Tools
      gcc
      clang
      jq
      ripgrep
      fzf
      gh
      nodejs_22
      pnpm
      bun

      # Text & Document Processing
      pandoc

      # Terminal Utilities
      tmux
      htop
      btop # Added for system monitoring

      # Media Processing
      ffmpeg
      imagemagick
    ]
    ++ (import ./vscode.nix {inherit pkgs;})
    ++ (import ./scripts.nix {inherit pkgs;});

  fonts.packages = with pkgs; [] ++ (import ./fonts.nix {inherit pkgs;});
}
