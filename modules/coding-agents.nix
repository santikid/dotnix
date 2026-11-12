{
  inputs,
  pkgs,
  ...
}: let
  llmAgents = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
in {
  environment.systemPackages = [
    pkgs.codex
    llmAgents.claude-code
  ];
}
