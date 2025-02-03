{
  config,
  pkgs,
  inputs,
  ...
}: {
  environment.systemPackages =
    []
    ++ (import ./scripts.nix {inherit pkgs;});
}
