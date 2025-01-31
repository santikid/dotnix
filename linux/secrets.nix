{
  config,
  pkgs,
  inputs,
  ...
}: {
  sops = {
    age = {
      keyFile = "${config.users.users.santi.home}/.config/sops/age/keys.txt";
      generateKey = false;
    };
    defaultSopsFile = ../secrets/linux.yaml;
    secrets = {
      pw_santi = {neededForUsers = true;};
    };
  };
}
