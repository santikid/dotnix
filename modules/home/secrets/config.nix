{config, ...}: {
  sops = {
    age = {
      keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
      generateKey = false;
    };
    defaultSopsFile = ../../../secrets/secrets.yaml;
    secrets = {
      gh_token = {};
    };
  };
}
