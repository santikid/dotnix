{
  config,
  pkgs,
  inputs,
  ...
}: {
  services.openssh.enable = true;
  services.tailscale.enable = true;

  power.restartAfterPowerFailure = true;
  power.restartAfterFreeze = true;
}
