{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.traefik;

  format = pkgs.formats.toml {};

  dynamicConfigFile = format.generate "config.toml" cfg.dynamicConfigOptions;

  staticConfigFile = format.generate "config.toml" (recursiveUpdate cfg.staticConfigOptions {
      providers.file.filename = "${dynamicConfigFile}";
    });
in {
  options.services.traefik = {
    enable = mkEnableOption "Traefik web server";

    staticConfigOptions = mkOption {
      description = ''
        Static configuration for Traefik.
      '';
      type = format.type;
      default = { entryPoints.http.address = ":80"; };
      example = {
        entryPoints.web.address = ":8080";
        entryPoints.http.address = ":80";

        api = { };
      };
    };

    dynamicConfigOptions = mkOption {
      description = ''
        Dynamic configuration for Traefik.
      '';
      type = format.type;
      default = { };
      example = {
        http.routers.router1 = {
          rule = "Host(`localhost`)";
          service = "service1";
        };

        http.services.service1.loadBalancer.servers =
          [{ url = "http://localhost:8080"; }];
      };
    };

    dataDir = mkOption {
      default = "/var/lib/traefik";
      type = types.path;
      description = ''
        Location for any persistent data traefik creates, ie. acme
      '';
    };

    package = mkPackageOption pkgs "traefik" { };
  };

  config = mkIf cfg.enable {
    launchd.daemons.traefik = {
      serviceConfig = {
        Label = "io.traefik.traefik";
        RunAtLoad = true;
      };
      script = ''
        export CF_API_EMAIL=`cat /run/secrets/cf_email`
        export CF_DNS_API_TOKEN=`cat /run/secrets/cf_token`
        ${cfg.package}/bin/traefik --configfile=${staticConfigFile}
      '';
    };
    users.users.traefik = {
      name = "traefik";
      home = mkDefault "/var/lib/traefik";
      shell = "/bin/bash";
      description = "Traefik web server";
    };
  };
}
