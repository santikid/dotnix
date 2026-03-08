{
  config,
  pkgs,
  user,
  ...
}: {
  networking.nameservers = ["1.1.1.1" "1.0.0.1"];
  networking.networkmanager.dns = "none";

  security.polkit.enable = true;

  fonts.fontDir.enable = true;

  environment.systemPackages = with pkgs; [
    coreutils
    gnumake
    fd

    curl
    wget

    zip
    watch

    gcc
    clang

    libvterm
    ghostty
  ];

  users.users.${user.name} = {
    isNormalUser = true;
    home = "/home/${user.name}";
    description = user.description;
    shell = pkgs.zsh;
    extraGroups = ["wheel" "video" "audio"];
    openssh.authorizedKeys.keys = user.sshKeys;
  };

  security.sudo.extraRules = [
    {
      users = [user.name];
      commands = [
        {
          command = "${config.system.build.nixos-rebuild}/bin/nixos-rebuild";
          options = ["NOPASSWD"];
        }
      ];
    }
  ];
}
