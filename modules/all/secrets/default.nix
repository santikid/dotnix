{
  config,
  pkgs,
  inputs,
  user,
  ...
}: {
  sops = {
    age = {
      generateKey = false;
    };
    defaultSopsFile = ../../../secrets/secrets.yaml;
    secrets = {
      cf_token = {};
      cf_email = {};
    };
  };
}
