{ lib, config, ... }:

with lib;

let
  cfg = config.homelab.services.blocky;
in
{
  options = {
    homelab.modules.boot.enable = mkEnableOption "Boot configuration";
  };

  config = mkIf cfg.enable {
    # Use the systemd-boot EFI boot loader.
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;
    boot.growPartition = true;
  };
}
