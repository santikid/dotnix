{
  config,
  lib,
  pkgs,
  utils,
  ...
}: let
  secrets = config.sops.secrets;
  repository = "/storage/restic/opal";

  # Shared by copy, retention and integrity checks; never put passwords in argv.
  resticCommand = args:
    utils.escapeSystemdExecArgs ([
        (lib.getExe pkgs.restic)
        "--cache-dir"
        "/var/cache/restic-copy"
        "--repo"
        repository
        "--password-file"
        secrets.restic_copy_opal_destination_password.path
        "--retry-lock"
        "2h"
      ]
      ++ args);

  repositoryChecks = {
    RequiresMountsFor = ["/storage"];
    AssertPathIsMountPoint = "/storage";
    AssertPathExists = "${repository}/config";
  };

  resticService = {
    Type = "oneshot";
    TimeoutStartSec = "infinity";
    CacheDirectory = "restic-copy";
    CacheDirectoryMode = "0700";
  };
in {
  sops.secrets = lib.genAttrs [
    "restic_copy_source_ssh_config"
    "restic_copy_source_ssh_key"
    "restic_copy_source_known_hosts"
    "restic_copy_opal_source_repository"
    "restic_copy_opal_source_password"
    "restic_copy_opal_destination_password"
    "restic_copy_healthchecks_curl_config"
  ] (_: {sopsFile = ../../secrets/lime.yaml;});

  fileSystems."/storage" = {
    device = "/dev/disk/by-label/lime-storage";
    fsType = "btrfs";
    options = [
      "compress=zstd:3"
      "noatime"
      "nofail"
      "x-systemd.device-timeout=30s"
    ];
  };

  services.btrfs.autoScrub.fileSystems = ["/storage"];
  services.ntfy-maintenance-alerts.systemdServices = [
    "btrfs-scrub-storage"
    "restic-copy-opal"
    "restic-copy-maintenance-opal"
  ];

  systemd.services = {
    restic-copy-opal = {
      description = "Copy opal Restic snapshots to local storage";
      wants = ["network-online.target"];
      after = ["network-online.target"];
      path = [pkgs.openssh];
      unitConfig = repositoryChecks;
      serviceConfig =
        resticService
        // {
          ExecStart = resticCommand [
            "-o"
            "sftp.args=-F ${secrets.restic_copy_source_ssh_config.path}"
            "copy"
            "--from-repository-file"
            secrets.restic_copy_opal_source_repository.path
            "--from-password-file"
            secrets.restic_copy_opal_source_password.path
          ];
        };
    };

    # Keep the public entry point and send success only after the copy succeeds.
    restic-copy = {
      description = "Copy remote Restic snapshots to local storage";
      requires = ["restic-copy-opal.service"];
      after = ["restic-copy-opal.service"];
      startAt = "*-*-* 06:00:00";
      serviceConfig = {
        Type = "oneshot";
        TimeoutStartSec = "infinity";
        ExecStart = utils.escapeSystemdExecArgs [
          (lib.getExe pkgs.curl)
          "--config"
          secrets.restic_copy_healthchecks_curl_config.path
          "--fail-with-body"
          "--silent"
          "--show-error"
          "--max-time"
          "10"
          "--retry"
          "5"
          "--output"
          "/dev/null"
        ];
      };
    };

    restic-copy-maintenance-opal = {
      description = "Maintain the copied opal Restic repository";
      startAt = "*-*-01 10:00:00";
      unitConfig = repositoryChecks;
      serviceConfig =
        resticService
        // {
          ExecStart = [
            (resticCommand [
              "forget"
              "--prune"
              "--keep-hourly"
              "24"
              "--keep-daily"
              "30"
              "--keep-monthly"
              "12"
            ])
            (resticCommand ["check" "--read-data-subset=5%"])
          ];
        };
    };
  };
}
