{
  inputs,
  pkgs,
  user,
  ...
}: let
  piPackage = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.pi;
in {
  home-manager.users.${user.name} = {
    config,
    lib,
    ...
  }: {
    programs.pi-coding-agent = {
      enable = true;
      package = piPackage;
      settings = {
        defaultProvider = "openai-codex";
        defaultModel = "gpt-5.6-sol";
        defaultThinkingLevel = "high";
        enabledModels = ["openai-codex/gpt-5.6-*"];
        packages = [
          "npm:@gotgenes/pi-permission-system@20.9.0"
          "npm:pi-ask-user@0.13.0"
          "npm:pi-subagents@0.35.1"
          "npm:pi-web-access@0.13.0"
          "npm:pi-slopchop@0.10.1"
          "npm:@tmustier/pi-usage-extension@0.9.1"
        ];
      };
    };

    home.file = {
      "${config.programs.pi-coding-agent.configDir}/skills/tasks".source =
        config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.nix/configs/pi/skills/tasks";

      "${config.programs.pi-coding-agent.configDir}/extensions/pi-permission-system/config.json".source =
        config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.nix/configs/pi/permission-system.json";
    };

    # Herdr ships its Pi lifecycle integration in the Herdr binary. Install the
    # matching bundled version on every activation instead of tracking another
    # third-party Pi package or a copied extension.
    home.activation = lib.mkIf (config.programs.herdr.enable && config.programs.herdr.package != null) {
      installHerdrPiIntegration = lib.hm.dag.entryAfter ["writeBoundary"] ''
        $DRY_RUN_CMD mkdir -p ${lib.escapeShellArg "${config.programs.pi-coding-agent.configDir}/extensions"}
        $DRY_RUN_CMD ${pkgs.coreutils}/bin/env \
          PI_CODING_AGENT_DIR=${lib.escapeShellArg config.programs.pi-coding-agent.configDir} \
          ${lib.getExe config.programs.herdr.package} integration install pi
      '';
    };
  };
}
