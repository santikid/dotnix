{
  lib,
  config,
  modulesPath,
  user,
  ...
}: {
  imports = [
    "${modulesPath}/virtualisation/lxc-container.nix"
  ];

  nix.settings.trusted-users = ["root" "@wheel" user.name];
  nix.settings.extra-platforms = [
    "x86_64-linux"
    "i686-linux"
  ];

  users.mutableUsers = false;
  users.groups.orbstack.gid = 67278;
  users.users.${user.name} = {
    uid = 501;
    group = "users";
    isNormalUser = lib.mkForce false;
    isSystemUser = true;
    createHome = true;
    homeMode = "700";
    extraGroups = ["orbstack"];
  };

  security.sudo.wheelNeedsPassword = false;

  environment.shellInit = ''
    . /opt/orbstack-guest/etc/profile-early
    . /opt/orbstack-guest/etc/profile-late
  '';

  documentation = {
    man.enable = true;
    doc.enable = true;
    info.enable = true;
  };

  services.resolved.enable = false;
  networking = {
    dhcpcd.enable = false;
    useDHCP = false;
    useHostResolvConf = false;
    resolvconf.enable = false;
  };
  environment.etc."resolv.conf".source = "/opt/orbstack-guest/etc/resolv.conf";

  systemd.network = {
    enable = true;
    networks."50-eth0" = {
      matchConfig.Name = "eth0";
      networkConfig = {
        DHCP = "ipv4";
        IPv6AcceptRA = true;
      };
      linkConfig.RequiredForOnline = "routable";
    };
  };

  systemd.suppressedSystemUnits = [
    "sys-kernel-debug.mount"
    "sys-kernel-tracing.mount"
  ];

  services.openssh.enable = false;

  systemd.services."systemd-oomd".serviceConfig.WatchdogSec = 0;
  systemd.services."systemd-userdbd".serviceConfig.WatchdogSec = 0;
  systemd.services."systemd-udevd".serviceConfig.WatchdogSec = 0;
  systemd.services."systemd-timesyncd".serviceConfig.WatchdogSec = 0;
  systemd.services."systemd-timedated".serviceConfig.WatchdogSec = 0;
  systemd.services."systemd-portabled".serviceConfig.WatchdogSec = 0;
  systemd.services."systemd-nspawn@".serviceConfig.WatchdogSec = 0;
  systemd.services."systemd-machined".serviceConfig.WatchdogSec = 0;
  systemd.services."systemd-localed".serviceConfig.WatchdogSec = 0;
  systemd.services."systemd-logind".serviceConfig.WatchdogSec = 0;
  systemd.services."systemd-journald@".serviceConfig.WatchdogSec = 0;
  systemd.services."systemd-journald".serviceConfig.WatchdogSec = 0;
  systemd.services."systemd-journal-remote".serviceConfig.WatchdogSec = 0;
  systemd.services."systemd-journal-upload".serviceConfig.WatchdogSec = 0;
  systemd.services."systemd-importd".serviceConfig.WatchdogSec = 0;
  systemd.services."systemd-hostnamed".serviceConfig.WatchdogSec = 0;
  systemd.services."systemd-homed".serviceConfig.WatchdogSec = 0;
  systemd.services."systemd-networkd".serviceConfig.WatchdogSec = lib.mkIf config.systemd.network.enable 0;

  programs.ssh.extraConfig = ''
    Include /opt/orbstack-guest/etc/ssh_config
  '';

  home-manager.users.${user.name} = {
    home.sessionPath = [
      "$HOME/.npm-global/bin"
    ];

    home.sessionVariables = {
      NPM_CONFIG_PREFIX = "$HOME/.npm-global";
    };
  };

  system.stateVersion = "26.11";
}
