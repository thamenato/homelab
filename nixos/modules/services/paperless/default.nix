{
  pkgs,
  lib,
  config,
  ...
}:

with lib;

let
  cfg = config.homelab.modules.services.paperless;
in
{
  options = {
    homelab.modules.services.paperless.enable = mkEnableOption "Enable Paperless-ngx";
  };

  config =
    let
      dataDir = "/mnt/paperless";
      hostName = "paperless.cthyllaxy.xyz";
    in
    mkIf cfg.enable {
      fileSystems = {
        # mount unraid user share to VM using 9p
        "${dataDir}" = {
          device = "paperless";
          fsType = "virtiofs";
          options = [
            "nofail"
            "rw"
            "relatime"
          ];
        };
      };

      sops.secrets.paperlessAdminPasswd = {
        owner = "paperless";
      };

      services.paperless = {
        enable = true;
        passwordFile = config.sops.secrets.paperlessAdminPasswd.path;
        dataDir = dataDir;
        settings = {
          PAPERLESS_URL = "https://${hostName}";
          USE_X_FORWARD_HOST = true;
          USE_X_FORWARD_PORT = true;
          PAPERLESS_DBHOST = "/run/postgresql";
        };
      };

      systemd.services = {
        paperless-scheduler.after = [ "mnt-paperless.mount" ];
        paperless-consumer.after = [ "mnt-paperless.mount" ];
        paperless-web.after = [ "mnt-paperless.mount" ];
      };

      services.postgresql = {
        enable = true;
        package = pkgs.postgresql_16;
        ensureDatabases = [ "paperless" ];
        ensureUsers = [
          {
            name = "paperless";
            ensureDBOwnership = true;
          }
        ];
      };

      services.nginx.virtualHosts.${hostName} = {
        forceSSL = true;
        sslCertificate = config.sops.secrets.cthyllaxyCert.path;
        sslCertificateKey = config.sops.secrets.cthyllaxyPrivKey.path;

        locations."/" = {
          proxyPass = "http://localhost:28981";
          extraConfig = ''
            # These configuration options are required for WebSockets to work.
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";

            proxy_redirect off;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Host $server_name;
            add_header Referrer-Policy "strict-origin-when-cross-origin";

            client_max_body_size 100M;
          '';
        };
      };

      networking.firewall = {
        allowedTCPPorts = [
          80
          443
        ];
      };
    };
}

/*
  References:
  - https://search.nixos.org/options?channel=unstable&show=services.paperless.settings&from=0&size=200&sort=relevance&type=packages&query=services.paperless
  - https://github.com/paperless-ngx/paperless-ngx/wiki/Using-a-Reverse-Proxy-with-Paperless-ngx#nginx
*/
