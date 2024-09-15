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
  options = {
    homelab.modules.services.nextcloud.enable = mkEnableOption "Enable Nextcloud";
  };

  config =
    let
      dataDir = "/mnt/nextcloud";
      hostName = "nextcloud.cthyllaxy.xyz";
    in
    mkIf cfg.enable {
      fileSystems = {
        # mount unraid user share to VM using 9p
        "${dataDir}" = {
          device = "nextcloud";
          fsType = "virtiofs";
          options = [
            "nofail"
            "rw"
            "relatime"
          ];
        };
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
        datadir = "${dataDir}";

        config = {
          adminpassFile = config.sops.secrets.nextcloudAdminPasswd.path;
        };

        extraApps = {
          inherit (config.services.nextcloud.package.packages.apps) calendar tasks;
        };
        extraAppsEnable = true;
        appstoreEnable = false;
      };

      systemd.services.nextcloud-setup.after = [ "mnt-paperless.mount" ];

      services.nginx.virtualHosts.${hostName} = {
        forceSSL = true;
        sslCertificate = config.sops.secrets.cthyllaxyCert.path;
        sslCertificateKey = config.sops.secrets.cthyllaxyPrivKey.path;
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
