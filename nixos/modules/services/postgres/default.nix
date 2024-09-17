{
  lib,
  config,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.homelab.modules.services.postgres;
in
{
  options = {
    homelab.modules.services.postgres.enable = mkEnableOption "Enable Postgres Configs";
    homelab.modules.services.postgres.dataDir = mkOption {
      type = types.str;
      default = "${config.homelab.modules.services.dataDir}/postgres";
      description = "Path to store PostgreSQL data";
    };
  };

  config = lib.mkIf cfg.enable {
    services.postgresql = {
      enable = true;
      package = pkgs.postgresql_16;
      dataDir = cfg.dataDir;
    };
  };
}
