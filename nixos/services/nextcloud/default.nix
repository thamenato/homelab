{ lib, config, pkgs, ... }:

with lib;

let
  cfg = config.homelab.services.nextcloud;
in
{
  options = {
    homelab.services.nextcloud.enable = mkEnableOption "Enable Nextcloud";
  };

  config =
    let
      homeDir = "/var/lib/nextcloud";
    in
    mkIf cfg.enable
      {
        environment.etc."nextcloud-admin-pass".text = "justatest";

        fileSystems = {
          # mount unraid user share to VM using 9p
          "/mnt/nextcloud" = {
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
          datadir = "/mnt/nextcloud";
          config.adminpassFile = "/etc/nextcloud-admin-pass";

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
