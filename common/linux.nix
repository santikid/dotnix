{
  config,
  pkgs,
  inputs,
  ...
}: {
  environment.systemPackages = with pkgs;
    [
    ]
    ++ (import ../packages/system.nix {inherit pkgs;});
}
