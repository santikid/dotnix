{
  pkgs,
  user,
  ...
}: {
  networking.firewall.trustedInterfaces = ["incusbr0"];

  virtualisation = {
    docker = {
      enable = true;
      autoPrune = {
        enable = true;
        dates = "weekly";
        flags = ["--filter=until=30d"];
      };
      daemon.settings = {
        "firewall-backend" = "nftables";
        "live-restore" = false;
      };
    };
    incus.enable = true;
  };

  systemd.services.docker.path = [pkgs.nftables];

  users.users.${user.name}.extraGroups = [
    "docker"
    "incus-admin"
  ];

  environment.systemPackages = [pkgs.docker-compose];
}
