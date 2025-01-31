
{
  config,
  pkgs,
  inputs,
  environment,
  ...
}: {
  sops = {
    age = {
        keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
        generateKey = false;
    };
    defaultSopsFile = ../../secrets/secrets.yaml;
    secrets = {
        gh_token = {};
        # e.g. secret_x.path = "${config.home.homeDirectory}/.config/secret/important.svg"
    };
  };
  # programs.zsh.interactiveShellInit = ''
  #   set -x GH_TOKEN (${pkgs.coreutils}/bin/cat ${config.sops.secrets.gh_token.path} 2>/dev/null)
  # '';
}
