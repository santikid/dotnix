{
  config,
  pkgs,
  ...
}: {
  # Scheduled ahead of Backrest's 04:00 backup; there is no ordering dependency.
  systemd.services.incus-export-ruby = {
    description = "Export Ruby for the off-site backup";
    requires = ["incus.service"];
    wants = ["storage-pool.service"];
    after = ["incus.service" "storage-pool.service"];
    path = [
      config.virtualisation.incus.package
      pkgs.coreutils
      pkgs.gnutar
      pkgs.util-linux
      pkgs.zstd
    ];
    serviceConfig = {
      Type = "oneshot";
      UMask = "0077";
      TimeoutStartSec = "3h";
    };
    script = ''
      set -euo pipefail

      # Never put a large VM export on the internal disks if ZFS is offline.
      if [[ "$(findmnt -rn -M /storage/backups -o SOURCE,FSTYPE)" != "storage/data/backups zfs" ]]; then
        echo "The storage/backups dataset is not mounted; refusing to export." >&2
        exit 1
      fi

      backup_dir=/storage/backups/incus
      install -d -m 0700 "$backup_dir"
      # Exclude .ruby-export-* in Backrest in case a catch-up run overlaps it.
      staging=$(mktemp "$backup_dir/.ruby-export-XXXXXXXX")
      trap 'rm -f -- "$staging"' EXIT
      trap 'exit 143' TERM
      trap 'exit 130' INT

      # Portable export; omit snapshots (including temporary repair snapshots).
      # A live export is not a replacement for application-consistent DB backups.
      incus --force-local --project default export ruby \
        "$staging" --force --instance-only --compression=zstd
      test -s "$staging"
      zstd -dc -- "$staging" | tar -tf - >/dev/null
      chmod 0600 "$staging"
      mv -fT -- "$staging" "$backup_dir/ruby.tar.zst"
      echo "Updated $backup_dir/ruby.tar.zst"
    '';
  };

  systemd.timers.incus-export-ruby = {
    description = "Refresh Ruby's export before the 04:00 Backrest backup";
    wantedBy = ["timers.target"];
    timerConfig = {
      OnCalendar = "*-*-* 00:00:00 Europe/Lisbon";
      Persistent = true;
    };
  };

  services.ntfy-maintenance-alerts.systemdServices = ["incus-export-ruby"];
}
