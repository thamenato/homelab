{ lib, config, ... }:

with lib;

let
  cfg = config.homelab.modules.services.owncloud;
in
{
  options.homelab.modules.services.owncloud = {
    enable = mkEnableOption "Enable ownCloud";
    dataDir = mkOption {
      type = types.str;
      default = "${config.homelab.modules.services.dataDir}/ocis";
      description = "Path to store data";
    };
    systemdMnt = mkOption {
      type = types.str;
      default = "mnt-data.mount";
      description = "Systemd mount unit for the dataDir";
    };
    hostName = mkOption {
      type = types.str;
      default = "ocis.cthyllaxy.xyz";
      description = "Hostname to use with Paperless";
    };
  };

  config =
    let
      ocisURL = "https://${cfg.hostName}";
    in
    mkIf cfg.enable {
      nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [ "ocis-bin" ];

      sops.secrets.ocisEnvironmentFile = {
        owner = "ocis";
      };

      services.ocis = {
        enable = true;

        url = ocisURL;
        stateDir = cfg.dataDir;
        configDir = "${cfg.dataDir}/config";
        environment = {
          OCIS_LOG_LEVEL = "info";
          PROXY_TLS = "false";
          OCIS_INSECURE = "false";
          PROXY_HTTP_ADDR = "0.0.0.0:9200";
        };
        # environmentFile = config.sops.secrets.ocisEnvironmentFile.path;
      };

      services.nginx.virtualHosts.${cfg.hostName} =
        let
          proxyPass = "http://${config.services.ocis.address}:${toString config.services.ocis.port}";
        in
        {
          forceSSL = true;
          sslCertificate = config.sops.secrets.sslCertificate.path;
          sslCertificateKey = config.sops.secrets.sslCertificateKey.path;

          locations."/" = {
            proxyPass = proxyPass;
            extraConfig = ''
              # OIDC Tokens in headers are quite large and can exceed default limits of reverse proxies
              proxy_buffers 4 256k;
              proxy_buffer_size 128k;
              proxy_busy_buffers_size 256k;

              # Disable checking of client request body size
              client_max_body_size 0;

              proxy_http_version 1.1;
              proxy_pass_header Content-Type;
              proxy_redirect off;

              proxy_set_header Host $host;
              proxy_set_header Origin https://ocis.cthyllaxy.xyz;
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
