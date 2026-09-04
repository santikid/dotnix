{
  config,
  lib,
  pkgs,
  ...
}: {
  sops = {
    age = {
      generateKey = false;
      sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
    };
    defaultSopsFile = ../../secrets/opal.yaml;
    secrets.attic_jwt_secret = {};
    templates."atticd.env" = {
      content = ''
        ATTIC_SERVER_TOKEN_RS256_SECRET_BASE64="${config.sops.placeholder.attic_jwt_secret}"
      '';
      restartUnits = ["atticd.service"];
    };
  };

  services.atticd = {
    enable = true;
    environmentFile = config.sops.templates."atticd.env".path;
    settings = {
      listen = "[::]:8180";
      "api-endpoint" = "http://opal:8180/";
      "allowed-hosts" = [
        "opal:8180"
        "localhost:8180"
        "127.0.0.1:8180"
      ];
      database.url = "sqlite:///srv/Attic/server.db?mode=rwc";
      storage = {
        type = "local";
        path = "/storage/attic";
      };
      chunking = {
        "nar-size-threshold" = 0;
        "min-size" = 65536;
        "avg-size" = 131072;
        "max-size" = 262144;
      };
      "garbage-collection" = {
        interval = "12 hours";
        "default-retention-period" = "90 days";
      };
    };
  };

  users = {
    groups.atticd = {};
    users.atticd = {
      isSystemUser = true;
      group = "atticd";
    };
  };

  systemd = {
    tmpfiles.rules = ["d /srv/Attic 0700 atticd atticd -"];
    services.atticd = {
      after = ["storage-pool.service"];
      wants = ["storage-pool.service"];
      unitConfig.ConditionPathIsMountPoint = "/storage";
      serviceConfig = {
        DynamicUser = lib.mkForce false;
        ExecStartPre = [
          "+${pkgs.coreutils}/bin/install -d -m 0700 -o atticd -g atticd /storage/attic"
        ];
        ReadWritePaths = ["/srv/Attic"];
      };
    };
  };
}
