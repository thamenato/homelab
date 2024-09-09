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
        hostName = "nextcloud.home";
        datadir = "${dataDir}";
        config.adminpassFile = config.sops.secrets.nextcloudAdminPasswd.path;

        extraApps = {
          inherit (config.services.nextcloud.package.packages.apps) calendar tasks;
        };
        extraAppsEnable = true;
        appstoreEnable = false;
      };

      systemd.services.nextcloud-setup.after = [ "mnt-paperless.mount" ];

      networking.firewall = {
        allowedTCPPorts = [ 80 ];
      };
    };
}

/*
  References:
  - https://carlosvaz.com/posts/the-holy-grail-nextcloud-setup-made-easy-by-nixos/
  - https://wiki.nixos.org/wiki/Nextcloud
  - https://nixos.wiki/wiki/Nextcloud
*/
