{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.ntfy-maintenance-alerts;
  hostName = config.networking.hostName;
  ntfyBaseUrl = lib.removeSuffix "/" cfg.baseUrl;

  notifyNtfy = pkgs.writeShellApplication {
    name = "notify-ntfy-maintenance";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.curl
    ];
    text = ''
      if (( $# != 4 )); then
        echo "usage: notify-ntfy-maintenance TITLE TAGS PRIORITY MESSAGE" >&2
        exit 64
      fi

      title=$1
      tags=$2
      priority=$3
      message=$4

      topic=$(tr -d '\r\n' < ${lib.escapeShellArg (toString cfg.topicFile)})
      if [[ ! $topic =~ ^[a-zA-Z0-9_-]+$ ]]; then
        echo "ntfy maintenance topic is empty or contains invalid characters" >&2
        exit 65
      fi

      curl \
        --fail \
        --silent \
        --show-error \
        --connect-timeout 5 \
        --max-time 15 \
        --retry 2 \
        --retry-all-errors \
        --retry-delay 2 \
        --output /dev/null \
        --header "Title: $title" \
        --header "Tags: $tags" \
        --header "Priority: $priority" \
        --data-raw "$message" \
        ${lib.escapeShellArg ntfyBaseUrl}/"$topic"
    '';
  };

  notifySmartd = pkgs.writeShellApplication {
    name = "notify-ntfy-smartd";
    runtimeInputs = [pkgs.coreutils];
    text = ''
      message=$(cat)

      exec ${lib.getExe notifyNtfy} \
        ${lib.escapeShellArg "${hostName}: SMART warning"} \
        "warning,floppy_disk" \
        "max" \
        "$message"
    '';
  };

  failureTargets = lib.genAttrs cfg.systemdServices (_: {
    onFailure = ["ntfy-maintenance-alert@%N.service"];
  });
in {
  options.services.ntfy-maintenance-alerts = {
    enable = lib.mkEnableOption "ntfy alerts for maintenance failures";

    topicFile = lib.mkOption {
      type = lib.types.path;
      description = "Runtime file containing the ntfy topic name.";
    };

    baseUrl = lib.mkOption {
      type = lib.types.str;
      default = "https://ntfy.sh";
      description = "Base URL of the ntfy server.";
    };

    systemdServices = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      example = ["btrfs-scrub--" "smartd"];
      description = "Systemd service names to alert on, without the .service suffix.";
    };

    smartd.enable = lib.mkEnableOption "ntfy delivery for smartd warnings";
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = !cfg.smartd.enable || config.services.smartd.enable;
        message = "services.ntfy-maintenance-alerts.smartd.enable requires services.smartd.enable";
      }
    ];

    environment.systemPackages = [notifyNtfy];

    systemd.services =
      failureTargets
      // {
        "ntfy-maintenance-alert@" = {
          description = "Send an ntfy alert when %i.service fails";
          after = ["network-online.target"];
          wants = ["network-online.target"];
          scriptArgs = "%i";
          script = ''
            serviceName=$1
            exec ${lib.getExe notifyNtfy} \
              "${hostName}: $serviceName failed" \
              "x,gear" \
              "high" \
              "systemd service $serviceName.service failed. Inspect it with: journalctl -u $serviceName.service"
          '';
          serviceConfig.Type = "oneshot";
        };

        ntfy-maintenance-test = {
          description = "Send a test maintenance notification through ntfy";
          after = ["network-online.target"];
          wants = ["network-online.target"];
          script = ''
            exec ${lib.getExe notifyNtfy} ${lib.escapeShellArgs [
              "${hostName}: maintenance alerts enabled"
              "white_check_mark,gear"
              "default"
              "Declarative ntfy maintenance alerts are working."
            ]}
          '';
          serviceConfig.Type = "oneshot";
        };
      };

    services.smartd.notifications = lib.mkIf cfg.smartd.enable {
      mail = {
        enable = true;
        mailer = lib.getExe notifySmartd;
      };
      systembus-notify.enable = false;
      wall.enable = false;
      x11.enable = false;
    };
  };
}
