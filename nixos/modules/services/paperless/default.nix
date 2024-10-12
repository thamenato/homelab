{ lib, config, ... }:

with lib;

let
  cfg = config.homelab.modules.services.paperless;
in
{
  options.homelab.modules.services.paperless = {
    enable = mkEnableOption "Enable Paperless-ngx";
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

      services.paperless = {
        enable = true;
        passwordFile = config.sops.secrets.paperlessAdminPasswd.path;
        dataDir = dataDir;
        address = "10.0.10.3";
        settings = {
          PAPERLESS_URL = "https://${hostName}";
          USE_X_FORWARD_HOST = true;
          USE_X_FORWARD_PORT = true;
          PAPERLESS_DBHOST = "/run/postgresql";
        };
      };

      systemd.services = {
        paperless-scheduler.after = [
          cfg.systemdMnt
          "postgresql.service"
        ];
        paperless-consumer.after = [
          cfg.systemdMnt
          "postgresql.service"
        ];
        paperless-web.after = [
          cfg.systemdMnt
          "postgresql.service"
        ];
      };

      services.postgresql = {
        ensureDatabases = [ "paperless" ];
        ensureUsers = [
          {
            name = "paperless";
            ensureDBOwnership = true;
          }
        ];
      };

      networking.firewall = {
        allowedTCPPorts = [ config.services.paperless.port ];
      };
    };
}

/*
  References:
  - https://search.nixos.org/options?channel=unstable&show=services.paperless.settings&from=0&size=200&sort=relevance&type=packages&query=services.paperless
  - https://github.com/paperless-ngx/paperless-ngx/wiki/Using-a-Reverse-Proxy-with-Paperless-ngx#nginx
*/
