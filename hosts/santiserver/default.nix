{
  config,
  pkgs,
  inputs,
  user,
  ...
}: {
  imports = [
    ../../polyfills/darwin/traefik.nix
  ];
  home-manager.users.${user.name} = {
    home.sessionPath = [
      "/opt/podman/bin"
    ];
  };

  homebrew.casks = ["jellyfin" "podman-desktop"];
  networking = {
    dns = ["1.1.1.1" "9.9.9.9"];
    knownNetworkServices = ["Wi-Fi" "Ethernet"];
  };
  services.traefik = {
    enable = true;
    staticConfigOptions = {
      entryPoints = {
        web = {
          address = ":80";
          asDefault = true;
          http.redirections.entrypoint = {
            to = "websecure";
            scheme = "https";
          };
        };

        websecure = {
          address = ":443";
          asDefault = true;
          http.tls.certResolver = "letsencrypt";
        };
      };

      log = {
        level = "INFO";
        filePath = "${config.services.traefik.dataDir}/traefik.log";
        format = "json";
      };

      certificatesResolvers.letsencrypt.acme = {
        email = "postmaster@santi.gg";
        storage = "${config.services.traefik.dataDir}/acme.json";
        dnsChallenge = {
          provider = "cloudflare";
          resolvers = [
            "1.1.1.1:53"
          ];
        };
      };

      api.dashboard = true;
      api.insecure = true;
    };

    dynamicConfigOptions = {
      http.routers = {
        sonarr = {
          entryPoints = ["websecure"];
          rule = "Host(`shows.home.santi.cloud`)";
          service = "sonarr";
        };
        radarr = {
          entryPoints = ["websecure"];
          rule = "Host(`movies.home.santi.cloud`)";
          service = "radarr";
        };
        jellyfin = {
          entryPoints = ["websecure"];
          rule = "Host(`jellyfin.home.santi.cloud`)";
          service = "jellyfin";
        };
        sabnzbd = {
          entryPoints = ["websecure"];
          rule = "Host(`sabnzbd.home.santi.cloud`)";
          service = "sabnzbd";
        };
        traefik = {
          entryPoints = ["web"];
          rule = "Host(`traefik.home.santi.cloud`)";
          service = "api@internal";
        };
      };
      http.services = {
        sonarr = {
          loadBalancer = {
            servers = [
              {url = "http://localhost:8989";}
            ];
          };
        };
        radarr = {
          loadBalancer = {
            servers = [
              {url = "http://localhost:7878";}
            ];
          };
        };
        jellyfin = {
          loadBalancer = {
            servers = [
              {url = "http://localhost:8096";}
            ];
          };
        };
        sabnzbd = {
          loadBalancer = {
            servers = [
              {url = "http://localhost:8585";}
            ];
          };
        };
      };
    };
  };
}
