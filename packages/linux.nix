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

      # Text & Document Processing
      pandoc
    ]
    ++ (import ./scripts.nix {inherit pkgs;});
}
