{
  config,
  pkgs,
  inputs,
  user,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
  ];

  networking.useDHCP = true;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  virtualisation.docker.enable = true;

  virtualisation.incus.enable = true;
  networking.nftables.enable = true;

  users.users.${user.name}.extraGroups = ["docker" "incus-admin"];

  services.cloudflared = {
    enable = true;
    tunnels = {
      "0fe3d5d3-b10e-41d0-9b95-6520a5ca3ea4" = {
        credentialsFile = "${config.sops.secrets.cf_tunnel_santi_gg.path}";
        default = "http_status:404";
      };
    };
  };

  networking.firewall = {
    enable = true;
    trustedInterfaces = ["tailscale0" "incusbr0"];
    allowedTCPPorts = [80 443 25565 25566 25567];
  };

  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  services.borgmatic.enable = true;

  system.stateVersion = "24.05";
}
