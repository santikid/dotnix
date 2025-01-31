{
  config,
  pkgs,
  inputs,
  ...
}: {
  programs.gpg.enable = true;
  services.gpg-agent = {
    enable = true;
    enableScDaemon = true;
  };
}
