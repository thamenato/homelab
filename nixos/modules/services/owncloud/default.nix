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
      default = "${config.homelab.modules.services.dataDir}/paperless";
      description = "Path to store PostgreSQL data";
    };
    systemdMnt = mkOption {
      type = types.str;
      default = "mnt-data.mount";
      description = "Systemd mount unit for the dataDir";
    };
    hostName = mkOption {
      type = types.str;
      default = "paperless.cthyllaxy.xyz";
      description = "Hostname to use with Paperless";
    };
  };

  config =
    let
      dataDir = cfg.dataDir;
      hostName = cfg.hostName;
    in
    mkIf cfg.enable {
      sops.secrets.paperlessAdminPasswd = {
        owner = "paperless";
      };

      services.ocis = {

      };

      services.nginx.virtualHosts.${hostName} = {
        forceSSL = true;
        sslCertificate = config.sops.secrets.sslCertificate.path;
        sslCertificateKey = config.sops.secrets.sslCertificateKey.path;

        locations."/" = {
          proxyPass = "http://${config.services.ocis.address}:${config.services.ocis.port}";
          extraConfig = ''
            # OIDC Tokens in headers are quite large and can exceed default limits of reverse proxies
            proxy_buffers 4 256k;
            proxy_buffer_size 128k;
            proxy_busy_buffers_size 256k;

            # Disable checking of client request body size
            client_max_body_size 0;

            proxy_set_header Host $host;
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
