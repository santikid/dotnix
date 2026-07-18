{
  inputs,
  pkgs,
  ...
}: let
  llmAgents = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
in {
  environment.systemPackages = [
    llmAgents.codex
    llmAgents.kimi-code
    llmAgents.opencode
  ];
}
