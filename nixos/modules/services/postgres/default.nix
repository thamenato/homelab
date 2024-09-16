{
  lib,
  config,
  pkgs,
  ...
}:

let
  cfg = config.homelab.modules.services.postgres;
in
{
  options = {
    homelab.modules.services.postgres.enable = lib.mkEnableOption "Enable Postgres Configs";
  };

  config = lib.mkIf cfg.enable {

    fileSystems = {
      "/mnt/data" = {
        device = "data";
        fsType = "virtiofs";
        options = [
          "nofail"
          "rw"
          "relatime"
        ];
      };
    };

    services.postgresql = {
      enable = true;
      packages = pkgs.postgres_16;
      dataDir = "/mnt/data/postgres";
    };
  };
}
