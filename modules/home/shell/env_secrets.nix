{
  config,
  pkgs,
  inputs,
  environment,
  ...
}: {
  programs.zsh.initExtraFirst = ''
    export GITHUB_TOKEN="$(cat ${config.sops.secrets.gh_token.path})"
  '';
}
