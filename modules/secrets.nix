{config, ...}: {
  sops = {
    age.generateKey = false;
    defaultSopsFile = ../secrets/secrets.yaml;
    secrets = {
      cf_tunnel_obsidian = {};
      attic_jwt_secret = {};
      attic_s3_access_key_id = {};
      attic_s3_secret_access_key = {};
    };
    templates."atticd.env" = {
      content = ''
        ATTIC_SERVER_TOKEN_RS256_SECRET_BASE64="${config.sops.placeholder.attic_jwt_secret}"
        AWS_ACCESS_KEY_ID="${config.sops.placeholder.attic_s3_access_key_id}"
        AWS_SECRET_ACCESS_KEY="${config.sops.placeholder.attic_s3_secret_access_key}"
      '';
    };
  };
}
