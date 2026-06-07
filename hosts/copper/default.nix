{
  lib,
  pkgs,
  user,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.networkmanager.enable = true;
  users.users.${user.name}.extraGroups = ["networkmanager"];

  hardware.parallels.enable = true;
  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [
      "prl-tools"
    ];

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
      X11Forwarding = false;
      AllowUsers = [user.name];
    };
  };

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
    publish = {
      enable = true;
      addresses = true;
      workstation = true;
    };
  };

  environment.systemPackages = [
    (pkgs.writeShellApplication {
      name = "codex";
      runtimeInputs = [pkgs.nodejs_24];
      text = ''
        exec npx --yes @openai/codex@latest "$@"
      '';
    })
  ];

  home-manager.users.${user.name} = {
    home.sessionPath = [
      "$HOME/.npm-global/bin"
    ];

    home.sessionVariables = {
      NPM_CONFIG_PREFIX = "$HOME/.npm-global";
      NPM_CONFIG_CACHE = "$HOME/.cache/npm";
    };
  };

  networking.firewall = {
    enable = true;
    allowedTCPPorts = [22];
  };

  system.stateVersion = "26.05";
}
