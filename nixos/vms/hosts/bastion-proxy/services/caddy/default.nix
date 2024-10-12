{ lib, config, ... }:

with lib;

let
  cfg = config.modules.services.caddy;
in
{
  options.modules.services.caddy = {
    enable = mkEnableOption "Enable Caddy";
  };

  config = lib.mkIf cfg.enable {
    sops.secrets.caddyEnv = {
      owner = config.services.caddy.user;
    };

    services.caddy = {
      enable = true;
      email = "acme@cthyllaxy.xyz";

      globalConfig = ''
        tls {
          acme_dns cloudflare {env.CF_API_TOKEN}
        }
      '';

      virtualHosts."paperless.cthyllaxy.xyz".extraConfig = ''
        reverse_proxy http://10.0.10.3:28981
      '';
    };

    systemd.services.caddy.enviroment = config.sops.secrets.caddyEnv.path;
  };
}
