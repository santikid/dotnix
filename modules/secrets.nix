{...}: {
  sops = {
    age.generateKey = false;
    defaultSopsFile = ../secrets/secrets.yaml;
    secrets = {
      cf_token = {};
      cf_email = {};
      cf_tunnel_santi_gg = {};
    };
  };
}
