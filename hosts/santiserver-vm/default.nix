{
  inputs,
  user,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.useDHCP = true;
  services.hydra = {
    enable = true;
    hydraURL = "http://0.0.0.0:3000";
    notificationSender = "hydra@localhost";
    useSubstitutes = true;
  };

  nix.distributedBuilds = true;
  nix.settings.trusted-users = ["@admin" "hydra" "hydra-queue-runner"];
  nix.buildMachines = [
    {
      hostName = "devbox";
      system = "x86_64-linux";
      protocol = "ssh";
      sshUser = "hydra-builder";
      sshKey = "/etc/hydra-builder-key";
      supportedFeatures = ["big-parallel" "kvm" "nixos-test" "benchmark"];
      maxJobs = 8;
    }
  ];
  nix.extraOptions = ''
    experimental-features = nix-command flakes
    builders-use-substitutes = true
  '';

  virtualisation.docker.enable = true;
  users.users.${user.name}.extraGroups = ["docker"];

  system.stateVersion = "24.05";
}
