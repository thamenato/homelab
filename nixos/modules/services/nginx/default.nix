{
  lib,
  config,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.homelab.modules.services.nginx;
in
{
  options.homelab.modules.services.nginx = {
    enable = mkEnableOption "Enable NGINX";
    ssl = mkOption {
      type = types.bool;
      default = true;
    };
  };

  config = lib.mkIf cfg.enable {

    sops.secrets = lib.mkIf cfg.ssl {
      sslCertificate = {
        owner = "nginx";
      };
      sslCertificateKey = {
        owner = "nginx";
      };
    };

    services.nginx = {
      enable = true;
      package = pkgs.nginxMainline;
    };
  };
}
