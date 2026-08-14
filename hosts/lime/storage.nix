{
  config,
  lib,
  pkgs,
  utils,
  ...
}: let
  storageMount = "/storage";
  sourceSshConfig = config.sops.secrets.restic_copy_source_ssh_config.path;
  healthchecksCurlConfig = config.sops.secrets.restic_copy_healthchecks_curl_config.path;
  restic = lib.getExe pkgs.restic;
  curl = lib.getExe pkgs.curl;
  resticCache = "/var/cache/restic-copy";

  enableTimers = false;
  copySchedule = "*-*-* 06:00:00";

  jobs = {
    obsidian = {
      sourceRepositoryFile = config.sops.secrets.restic_copy_obsidian_source_repository.path;
      destinationRepository = "${storageMount}/restic/obsidian";
      sourcePasswordFile = config.sops.secrets.restic_copy_obsidian_source_password.path;
      destinationPasswordFile = config.sops.secrets.restic_copy_obsidian_destination_password.path;
      maintenanceSchedule = "*-*-01 10:00:00";
      retentionArgs = [
        "--keep-daily"
        "7"
        "--keep-weekly"
        "4"
        "--keep-monthly"
        "6"
      ];
    };

    lisbon = {
      sourceRepositoryFile = config.sops.secrets.restic_copy_lisbon_source_repository.path;
      destinationRepository = "${storageMount}/restic/lisbon";
      sourcePasswordFile = config.sops.secrets.restic_copy_lisbon_source_password.path;
      destinationPasswordFile = config.sops.secrets.restic_copy_lisbon_destination_password.path;
      maintenanceSchedule = "*-*-02 10:00:00";
      retentionArgs = [
        "--keep-hourly"
        "24"
        "--keep-daily"
        "30"
        "--keep-monthly"
        "12"
      ];
    };
  };

  destinationCommand = job: commandArgs:
    utils.escapeSystemdExecArgs (
      [
        restic
        "--cache-dir"
        resticCache
        "--repo"
        job.destinationRepository
        "--password-file"
        job.destinationPasswordFile
        "--retry-lock"
        "2h"
      ]
      ++ commandArgs
    );

  copyCommand = job:
    destinationCommand job [
      "-o"
      "sftp.args=-F ${sourceSshConfig}"
      "copy"
      "--from-repository-file"
      job.sourceRepositoryFile
      "--from-password-file"
      job.sourcePasswordFile
    ];

  healthcheckCommand = utils.escapeSystemdExecArgs [
    curl
    "--config"
    healthchecksCurlConfig
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

  commonServiceConfig = {
    Type = "oneshot";
    TimeoutStartSec = "infinity";
  };

  resticServiceConfig =
    commonServiceConfig
    // {
      CacheDirectory = "restic-copy";
      CacheDirectoryMode = "0700";
    };

  commonUnitConfig = job: {
    RequiresMountsFor = [storageMount];
    AssertPathIsMountPoint = storageMount;
    AssertPathExists = "${job.destinationRepository}/config";
  };

  copyServices =
    lib.mapAttrs' (
      name: job:
        lib.nameValuePair "restic-copy-${name}" {
          description = "Copy ${name} Restic snapshots to local storage";
          wants = ["network-online.target"];
          after =
            ["network-online.target"]
            ++ lib.optional (name == "lisbon") "restic-copy-obsidian.service";
          path = [pkgs.openssh];
          unitConfig = commonUnitConfig job;
          serviceConfig = resticServiceConfig // {ExecStart = copyCommand job;};
        }
    )
    jobs;

  copyServiceNames = map (name: "restic-copy-${name}.service") (builtins.attrNames jobs);

  copyCoordinatorService = {
    restic-copy = {
      description = "Copy remote Restic snapshots to local storage";
      requires = copyServiceNames;
      after = copyServiceNames;
      startAt = lib.optional enableTimers copySchedule;
      serviceConfig = commonServiceConfig // {ExecStart = healthcheckCommand;};
    };
  };

  maintenanceServices =
    lib.mapAttrs' (
      name: job:
        lib.nameValuePair "restic-copy-maintenance-${name}" {
          description = "Maintain the copied ${name} Restic repository";
          startAt = lib.optional enableTimers job.maintenanceSchedule;
          unitConfig = commonUnitConfig job;
          serviceConfig =
            resticServiceConfig
            // {
              ExecStart = [
                (destinationCommand job ([
                    "forget"
                    "--prune"
                  ]
                  ++ job.retentionArgs))
                (destinationCommand job [
                  "check"
                  "--read-data-subset=5%"
                ])
              ];
            };
        }
    )
    jobs;
in {
  sops.secrets = lib.genAttrs [
    "restic_copy_source_ssh_config"
    "restic_copy_source_ssh_key"
    "restic_copy_source_known_hosts"
    "restic_copy_obsidian_source_repository"
    "restic_copy_obsidian_source_password"
    "restic_copy_obsidian_destination_password"
    "restic_copy_lisbon_source_repository"
    "restic_copy_lisbon_source_password"
    "restic_copy_lisbon_destination_password"
    "restic_copy_healthchecks_curl_config"
  ] (_: {sopsFile = ../../secrets/lime.yaml;});

  fileSystems.${storageMount} = {
    device = "/dev/disk/by-label/lime-storage";
    fsType = "btrfs";
    options = [
      "compress=zstd:3"
      "noatime"
      "nofail"
      "x-systemd.device-timeout=30s"
    ];
  };

  services.btrfs.autoScrub.fileSystems = [storageMount];

  services.ntfy-maintenance-alerts.systemdServices =
    ["btrfs-scrub-storage"]
    ++ (map (name: "restic-copy-${name}") (builtins.attrNames jobs))
    ++ (map (name: "restic-copy-maintenance-${name}") (builtins.attrNames jobs));

  systemd.services = copyServices // copyCoordinatorService // maintenanceServices;
}
