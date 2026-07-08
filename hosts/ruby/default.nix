{
  lib,
  modulesPath,
  user,
  ...
}: {
  imports = [
    "${modulesPath}/virtualisation/incus-virtual-machine.nix"
    ../../modules/common/npm-global.nix
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

  services.openssh.openFirewall = false;

  virtualisation.docker.enable = true;

  nix.settings.trusted-users = ["root" "@wheel" user.name];

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

  system.stateVersion = "26.05";
}
