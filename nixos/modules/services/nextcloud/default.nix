{
  lib,
  config,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.homelab.modules.services.nextcloud;
in
{
  options.homelab.modules.services.nextcloud = {
    enable = mkEnableOption "Enable Nextcloud";
  };

  config =
    let
      homeDir = "/mnt/data/nextcloud";
      # dataDir = "${homeDir}/data";
      hostName = "nextcloud.cthyllaxy.xyz";
    in
    mkIf cfg.enable {

      sops.secrets.nextcloudAdminPasswd = {
        owner = "nextcloud";
      };

      services.nextcloud = {
        enable = true;

        package = pkgs.nextcloud29;

        hostName = hostName;

        https = true;
        settings = {
          overwriteprotocol = "https";
        };
        maxUploadSize = "16G";

        # Let NixOS install and configure the database automatically.
        database.createLocally = true;

        # Let NixOS install and configure Redis caching automatically.
        configureRedis = true;

        # home = "${homeDir}";
        # datadir = "${homeDir}";

        config = {
          adminuser = "admin";
          adminpassFile = config.sops.secrets.nextcloudAdminPasswd.path;
          dbtype = "pgsql";
          dbhost = "/run/postgresql";
          defaultPhoneRegion = "US";
        };

        extraAppsEnable = true;
        extraApps = {
          # List of packaged nextcloud apps
          # https://github.com/NixOS/nixpkgs/blob/master/pkgs/servers/nextcloud/packages/nextcloud-apps.json

          inherit (config.services.nextcloud.package.packages.apps)
            calendar
            cookbook
            deck
            memories
            notes
            tasks
            ;
        };
      };

      systemd.services.nextcloud-setup.after = [ "mnt-data.mount" ];

      services.nginx.virtualHosts.${hostName} = {
        forceSSL = true;
        sslCertificate = config.sops.secrets.sslCertificate.path;
        sslCertificateKey = config.sops.secrets.sslCertificateKey.path;
      };

      services.postgresql = {
        ensureDatabases = [ "nextcloud" ];
        ensureUsers = [
          {
            name = "nextcloud";
            ensureDBOwnership = true;
          }
        ];
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
  - https://carlosvaz.com/posts/the-holy-grail-nextcloud-setup-made-easy-by-nixos/
  - https://wiki.nixos.org/wiki/Nextcloud
  - https://nixos.wiki/wiki/Nextcloud
*/
