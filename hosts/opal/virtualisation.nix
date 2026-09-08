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

  # Queue Docker with a boot/hot-plug import; its own guard still fails closed.
  systemd.services.storage-pool.wants = ["docker.service"];
  systemd.services.docker = {
    wants = ["storage-pool.service"];
    after = ["storage-pool.service"];
    path = [pkgs.nftables pkgs.util-linux];
    preStart = ''
      mount=$(findmnt -rn -M /storage/media -o SOURCE,FSTYPE || true)
      if [[ "$mount" != "storage/data/media zfs" ]]; then
        echo "Refusing to start Docker without storage/data/media mounted at /storage/media." >&2
        exit 1
      fi
    '';
  };

  users.users.${user.name}.extraGroups = [
    "docker"
    "incus-admin"
  ];

  environment.systemPackages = [pkgs.docker-compose];
}
