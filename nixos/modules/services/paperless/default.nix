{ lib, config, pkgs, ... }:

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
    in
    mkIf cfg.enable
      {
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

        environment.etc."paperless-admin-pass".text = "admin";
        services.paperless = {
          enable = true;
          passwordFile = "/etc/paperless-admin-pass";
          dataDir = dataDir;
          address = "10.0.10.3";
          # settings = {
          #   PAPERLESS_DBHOST = "/run/postgresql";
          # };
        };

        systemd.services.paperless-scheduler.after = [ "mnt-paperless.mount" ];
        systemd.services.paperless-consumer.after = [ "mnt-paperless.mount" ];
        systemd.services.paperless-web.after = [ "mnt-paperless.mount" ];

        # services.postgresql = {
        #   enable = true;
        #   package = pkgs.postgresql_16;
        #   ensureDatabases = [ "paperless" ];
        #   ensureUsers = [
        #     {
        #       name = "paperless";
        #       ensureDBOwnership = true;
        #     }
        #   ];
        # };

        networking.firewall = {
          allowedTCPPorts = [ 28981 ];
        };
      };
}

/*
  References:
  - https://carlosvaz.com/posts/the-holy-grail-nextcloud-setup-made-easy-by-nixos/
  - https://wiki.nixos.org/wiki/Nextcloud
  - https://nixos.wiki/wiki/Nextcloud
*/
