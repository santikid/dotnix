{
  config,
  pkgs,
  inputs,
  ...
}: {
  environment.systemPackages = with pkgs;
    [
      asahi-bless
    ]
    ++ (import ./scripts.nix {inherit pkgs;});
}
