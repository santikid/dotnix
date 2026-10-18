{
  networking = {
    useDHCP = false;
    dhcpcd.enable = false;
    useNetworkd = true;
  };

  # Keep the existing global DNS configuration instead of enabling resolved.
  services.resolved.enable = false;

  systemd.network.networks."10-ens3" = {
    matchConfig.Name = "ens3";
    networkConfig.DHCP = "no";
    linkConfig = {
      RequiredForOnline = "routable";
      RequiredFamilyForOnline = "ipv4";
    };
  };

  sops = {
    # Decrypt with Jade's local host key before networkd configures the link.
    useSystemdActivation = true;
    secrets.jade_networkd_ens3 = {
      sopsFile = ../../secrets/jade.yaml;
      path = "/run/systemd/network/10-ens3.network.d/50-address.conf";
      owner = "root";
      group = "systemd-network";
      mode = "0440";
      reloadUnits = ["systemd-networkd.service"];
    };
  };

  systemd.services.systemd-networkd = {
    requires = ["sops-install-secrets.service"];
    after = ["sops-install-secrets.service"];
  };
}
