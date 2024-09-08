{ config
, lib
, ...
}:

with lib;

let
  cfg = config.homelab.modules.nix;
in
{
  options.module = {
    homelab.modules.nix.enable = mkEnableOption "Nix configurations";
  };

  config = mkIf cfg.enable {
    nix = {
      package = pkgs.nixVersions.nix_2_23;
      settings = {
        experimental-features = [ "nix-command" "flakes" ];
        allowed-users = [ meta.user ];
        trusted-users = [ meta.user ];
      };
    };
  };
}
