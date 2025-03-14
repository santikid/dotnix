{config, pkgs, inputs, ...}: {
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
      extraEnvironment = { TMPDIR = "/tmp"; };
      extraPackages = with pkgs; [ curl ];
    };
  };

  networking.useDHCP = true;

  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  system.stateVersion = "24.05";
}
