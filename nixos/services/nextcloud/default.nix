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
          "${homeDir}" = {
            device = "nextcloud";
            fsType = "9p";
            options = [
              "rw"
              "relatime"
              "nofail"
              "access=client"
              "trans=virtio"
              "x-systemd.automount"
            ];
          };
        };

        services.nextcloud = {
          enable = true;
          package = pkgs.nextcloud29;
          hostName = "nextcloud.home";
          # datadir = dataDir;
          config.adminpassFile = "/etc/nextcloud-admin-pass";
        };

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
