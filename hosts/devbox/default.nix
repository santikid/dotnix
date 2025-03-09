{config, inputs, ...}: {
  imports = [
    ./hardware-configuration.nix
  ];

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";

  sops.secrets.github-runner-token = {sopsFile = ../../secrets/devbox.yaml;};
  services.github-runners = {
    roller = {
      enable = true;
      url = "https://github.com/santikid/roller";
      tokenFile = config.sops.secrets.github-runner-token.path;
    };
    work-1 = {
      enable = true;
      url = "https://github.com/arollalda";
      tokenFile = config.sops.secrets.github-runner-token.path;
    };
    work-2 = {
      enable = true;
      url = "https://github.com/arollalda";
      tokenFile = config.sops.secrets.github-runner-token.path;
    };
  };

  networking.useDHCP = true;

  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  system.stateVersion = "24.05";
}
