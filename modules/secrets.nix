{...}: {
  sops = {
    age.generateKey = false;
    defaultSopsFile = ../secrets/secrets.yaml;
    secrets = {
      cf_tunnel_obsidian = {};
    };
  };
}
