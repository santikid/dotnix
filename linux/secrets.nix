{
  config,
  pkgs,
  inputs,
  user,
  ...
}: {
  sops = {
    age = {
      keyFile = "${config.users.users.${user}.home}/.config/sops/age/keys.txt";
      generateKey = false;
    };
    defaultSopsFile = ../secrets/linux.yaml;
    secrets = {
      user_pw = {neededForUsers = true;};
    };
  };
}
