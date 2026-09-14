{
  pkgs,
  user,
  ...
}: {
  environment.systemPackages = [
    pkgs.python3
    pkgs.uv
    pkgs.ruff
    pkgs.pyright
  ];

  home-manager.users.${user.name}.xdg.configFile."uv/uv.toml".text =
    if pkgs.stdenv.hostPlatform.isLinux
    then ''
      # NixOS needs compatible interpreters supplied by Nix.
      python-preference = "only-system"
      python-downloads = "never"
    ''
    else ''
      # Prefer Nix's Python, allowing uv to supply other project versions.
      python-preference = "system"
    '';
}
