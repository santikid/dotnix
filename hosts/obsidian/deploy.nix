{
  lib,
  user,
  pkgs,
  ...
}: let
  deployPublicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBxYQ4vcxf2e00uStoptt1fM0Jn+GE8Kb8CIvTIFyWyC";

  runtimePath = lib.makeBinPath [
    pkgs.bash
    pkgs.docker-compose
    pkgs.gitMinimal
    pkgs.openssh
  ];

  deployScript = pkgs.replaceVars ./deploy.mjs {
    bashBinary = lib.getExe pkgs.bash;
    composeBinary = lib.getExe pkgs.docker-compose;
    deployHome = "/home/${user.name}";
    deployUser = user.name;
    gitBinary = lib.getExe pkgs.gitMinimal;
    inherit runtimePath;
    sshBinary = lib.getExe pkgs.openssh;
  };

  obsidianDeploy = pkgs.writeShellApplication {
    name = "obsidian-deploy";
    text = ''
      cleanEnvironment=(
        HOME=${lib.escapeShellArg "/home/${user.name}"}
        LANG=C.UTF-8
        LC_ALL=C.UTF-8
        LOGNAME=${lib.escapeShellArg user.name}
        PATH=${lib.escapeShellArg runtimePath}
        USER=${lib.escapeShellArg user.name}
      )
      if [[ -v SSH_ORIGINAL_COMMAND ]]; then
        cleanEnvironment+=("SSH_ORIGINAL_COMMAND=$SSH_ORIGINAL_COMMAND")
      fi

      exec ${lib.getExe' pkgs.coreutils "env"} -i \
        "''${cleanEnvironment[@]}" \
        ${lib.getExe pkgs.zx} ${deployScript} "$@"
    '';

    meta.description = "Restricted zx deployment helper for Obsidian Compose stacks";
  };

  deployAuthorizedKeys =
    if deployPublicKey == null
    then []
    else [
      ''restrict,command="${lib.getExe obsidianDeploy}" ${deployPublicKey}''
    ];
in {
  sops.secrets.ntfy_maintenance_topic.owner = user.name;
  users.users.${user.name}.openssh.authorizedKeys.keys = deployAuthorizedKeys;
  environment.systemPackages = [obsidianDeploy];
}
