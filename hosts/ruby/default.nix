{
  lib,
  modulesPath,
  user,
  ...
}: {
  imports = [
    "${modulesPath}/virtualisation/incus-virtual-machine.nix"
  ];

  networking = {
    dhcpcd.enable = false;
    useDHCP = false;
    useHostResolvConf = false;
    firewall = {
      enable = true;
      allowedTCPPorts = [];
      trustedInterfaces = ["tailscale0"];
    };
  };

  systemd.network = {
    enable = true;
    networks."50-enp5s0" = {
      matchConfig.Name = "enp5s0";
      networkConfig = {
        DHCP = "ipv4";
        IPv6AcceptRA = true;
      };
      linkConfig.RequiredForOnline = "routable";
    };
  };

  services.openssh.openFirewall = false;

  nix.settings.trusted-users = ["root" "@wheel" user.name];

  home-manager.users.${user.name} = {
    home.sessionPath = [
      "$HOME/.npm-global/bin"
    ];

    home.sessionVariables = {
      NPM_CONFIG_PREFIX = "$HOME/.npm-global";
    };
  };

  system.stateVersion = "26.05";
}
