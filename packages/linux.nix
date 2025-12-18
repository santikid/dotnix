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
      git
      fd

      # Networking & Download Tools
      curl
      wget

      # Archiving & File Management
      zip
      watch

      # Development Tools
      gcc
      clang

      libvterm

      # Text & Document Processing
      pandoc

      # Ghostty for Terminfo
      ghostty
    ]
    ++ (import ./scripts.nix {inherit pkgs;});
}
