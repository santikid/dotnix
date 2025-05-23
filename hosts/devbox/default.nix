{
  config,
  pkgs,
  inputs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
  ];

  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";

  users.users.hydra-builder = {
    description = "Hydra Builder User";
    home = "/home/hydra-builder";
    shell = pkgs.bash;
    extraGroups = [];
    isNormalUser = true;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEJhplY56I2REexfLgVDu9n9LNrxBb0gbZgxrv+sPwIX root@santiserver-vm"
    ];
  };
  nix.settings.trusted-users = ["root" "hydra-builder"];
  services.openssh.settings.AllowUsers = ["hydra-builder"];

  sops.secrets.github-runner-token = {sopsFile = ../../secrets/devbox.yaml;};
  services.github-runners = {
    roller = {
      enable = true;
      url = "https://github.com/santikid/roller";
      tokenFile = config.sops.secrets.github-runner-token.path;
      extraEnvironment = {TMPDIR = "/tmp";};
      extraPackages = with pkgs; [curl];
    };
  };

  networking.useDHCP = true;

  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  system.stateVersion = "24.05";
}
