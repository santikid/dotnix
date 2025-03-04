{
  config,
  pkgs,
  inputs,
  user,
  ...
}: {
  programs.git = {
    enable = true;
    userName = user.description;
    userEmail = user.email;
    extraConfig = {
      init.defaultBranch = "main";
    };
  };
}
