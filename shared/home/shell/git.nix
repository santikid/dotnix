{
  config,
  pkgs,
  inputs,
  ...
}: {
  programs.git = {
    enable = true;
    userName = "Lukas Santner";
    userEmail = "lukas@santi.gg";
    signing = {
      key = "644E FF24 8A9C A2D2 69C3 0A7A 6AA8 09E3 B3CC CA64";
      signByDefault = false;
    };
    extraConfig = {
      init.defaultBranch = "main";
    };
  };
}
