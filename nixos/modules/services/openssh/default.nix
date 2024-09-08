{ lib, config, ... }:

with lib;

let
  cfg = config.homelab.services.openssh;
in
{
  options = {
    homelab.services.openssh.enable = mkEnableOption "Enable OpenSSH";
  };

  config = mkIf cfg.enable {
    services.openssh = {
      enable = true;

      settings = {
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
      };
    };
  };
}
