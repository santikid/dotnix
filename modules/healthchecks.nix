{
  config,
  lib,
  options,
  pkgs,
  ...
}: let
  cfg = config.services.peerHealthcheck;
  ntfyBaseUrl = lib.removeSuffix "/" cfg.baseUrl;
  stateDirectory =
    if pkgs.stdenv.isDarwin
    then "/var/db/peer-healthcheck"
    else "/var/lib/peer-healthcheck";
  targetNames = builtins.attrNames cfg.targets;
  targetUrls = map (name: cfg.targets.${name}) targetNames;

  checker = pkgs.writeShellApplication {
    name = "peer-healthcheck";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.curl
    ];
    text = ''
      monitor=${lib.escapeShellArg config.networking.hostName}
      topic_file=${lib.escapeShellArg (toString cfg.topicFile)}
      state_dir=${lib.escapeShellArg stateDirectory}
      failure_threshold=${toString cfg.failureThreshold}
      timeout=${toString cfg.timeoutSeconds}
      target_names=(${lib.escapeShellArgs targetNames})
      target_urls=(${lib.escapeShellArgs targetUrls})

      install -d -m 0700 "$state_dir"

      if [[ ! -r $topic_file ]]; then
        echo "peer-healthcheck: cannot read ntfy topic at $topic_file" >&2
        exit 1
      fi

      ntfy_topic=$(tr -d '\r\n' < "$topic_file")
      if [[ ! $ntfy_topic =~ ^[a-zA-Z0-9_-]+$ ]]; then
        echo "peer-healthcheck: ntfy topic is empty or contains invalid characters" >&2
        exit 65
      fi
      ntfy_url=${lib.escapeShellArg ntfyBaseUrl}/$ntfy_topic

      notify() {
        local event=$1
        local target_name=$2
        local target_url=$3
        local title priority tags message

        if [[ $event == down ]]; then
          title="$monitor: $target_name is down"
          priority=high
          tags=rotating_light
          message="$monitor cannot reach $target_name at $target_url after $failure_threshold consecutive checks."
        else
          title="$monitor: $target_name recovered"
          priority=default
          tags=white_check_mark
          message="$monitor can reach $target_name at $target_url again."
        fi

        if ! printf 'url = "%s"\n' "$ntfy_url" | curl \
          --config - \
          --fail \
          --silent \
          --show-error \
          --connect-timeout 5 \
          --max-time "$timeout" \
          --retry 2 \
          --retry-all-errors \
          --retry-delay 2 \
          --header "Title: $title" \
          --header "Priority: $priority" \
          --header "Tags: $tags" \
          --data-raw "$message" \
          --output /dev/null; then
          echo "peer-healthcheck: failed to send $event notification for $target_name" >&2
          return 1
        fi

        echo "peer-healthcheck: sent $event notification for $target_name"
      }

      save_state() {
        local state_file=$1
        local status=$2
        local failures=$3
        local temporary_file

        temporary_file=$(mktemp "$state_file.tmp.XXXXXX")
        chmod 0600 "$temporary_file"
        printf '%s %s\n' "$status" "$failures" > "$temporary_file"
        mv "$temporary_file" "$state_file"
      }

      for index in "''${!target_names[@]}"; do
        target_name="''${target_names[$index]}"
        target_url="''${target_urls[$index]}"

        state_file="$state_dir/$target_name.state"
        previous_status=up
        failures=0

        if [[ -r $state_file ]]; then
          read -r previous_status failures < "$state_file" || true
          if [[ $previous_status != up && $previous_status != down ]]; then
            previous_status=up
          fi
          if [[ ! $failures =~ ^[0-9]+$ ]]; then
            failures=0
          fi
        fi

        if curl \
          --fail \
          --silent \
          --connect-timeout "$timeout" \
          --max-time "$timeout" \
          --output /dev/null \
          "$target_url"; then
          if [[ $previous_status == down ]]; then
            if notify recovered "$target_name" "$target_url"; then
              save_state "$state_file" up 0
            else
              save_state "$state_file" down 0
            fi
          else
            save_state "$state_file" up 0
          fi
          continue
        fi

        if [[ $previous_status == down ]]; then
          save_state "$state_file" down 0
          continue
        fi

        failures=$((failures + 1))
        if (( failures >= failure_threshold )); then
          if notify down "$target_name" "$target_url"; then
            save_state "$state_file" down 0
          else
            save_state "$state_file" up "$failure_threshold"
          fi
        else
          save_state "$state_file" up "$failures"
        fi
      done
    '';
  };

  checkerCommand = lib.getExe checker;
in {
  options.services.peerHealthcheck = {
    enable = lib.mkEnableOption "periodic peer healthchecks with ntfy notifications";

    topicFile = lib.mkOption {
      type = lib.types.path;
      description = "Runtime file containing the ntfy topic name.";
    };

    baseUrl = lib.mkOption {
      type = lib.types.str;
      default = "https://ntfy.sh";
      description = "Base URL of the ntfy server.";
    };

    targets = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = {};
      example.server = "http://server:9100/";
      description = "Named HTTP endpoints to monitor.";
    };

    intervalSeconds = lib.mkOption {
      type = lib.types.ints.positive;
      default = 60;
      description = "Number of seconds between healthcheck runs.";
    };

    timeoutSeconds = lib.mkOption {
      type = lib.types.ints.positive;
      default = 10;
      description = "Maximum number of seconds allowed for each HTTP or ntfy request.";
    };

    failureThreshold = lib.mkOption {
      type = lib.types.ints.positive;
      default = 3;
      description = "Number of consecutive failures required before sending a down notification.";
    };
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      assertions = [
        {
          assertion = cfg.targets != {};
          message = "services.peerHealthcheck.targets must contain at least one endpoint";
        }
        {
          assertion = lib.all (name: builtins.match "[A-Za-z0-9._-]+" name != null) (builtins.attrNames cfg.targets);
          message = "services.peerHealthcheck target names may only contain letters, numbers, dots, underscores, and hyphens";
        }
        {
          assertion = lib.all (url: lib.hasPrefix "http://" url || lib.hasPrefix "https://" url) (builtins.attrValues cfg.targets);
          message = "services.peerHealthcheck target URLs must use HTTP or HTTPS";
        }
      ];
    }

    (lib.optionalAttrs (options ? systemd) {
      systemd.services.peer-healthcheck = {
        description = "Check peer health and publish state changes to ntfy";
        wants = ["network-online.target"];
        after = ["network-online.target"];
        script = "exec ${checkerCommand}";
        serviceConfig = {
          Type = "oneshot";
          StateDirectory = "peer-healthcheck";
          StateDirectoryMode = "0700";
          UMask = "0077";
        };
      };

      systemd.timers.peer-healthcheck = {
        description = "Periodically check peer health";
        wantedBy = ["timers.target"];
        timerConfig = {
          OnBootSec = "${toString cfg.intervalSeconds}s";
          OnUnitActiveSec = "${toString cfg.intervalSeconds}s";
          AccuracySec = "5s";
        };
      };
    })

    (lib.optionalAttrs (options ? launchd) {
      launchd.daemons.peer-healthcheck = {
        command = checkerCommand;
        serviceConfig = {
          RunAtLoad = true;
          StartInterval = cfg.intervalSeconds;
          ProcessType = "Background";
          StandardOutPath = "/var/log/peer-healthcheck.log";
          StandardErrorPath = "/var/log/peer-healthcheck.log";
        };
      };
    })
  ]);
}
