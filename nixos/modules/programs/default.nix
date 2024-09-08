{
  config,
  lib,
  pkgs,
  ...
}:

with lib;

let
  cfg = config.homelab.modules.programs.systemPackages;
in
{
  options = {
    homelab.modules.programs.systemPackages.enable = mkEnableOption "NixOS system packages";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      git
      neovim
      htop
    ];
  };
}
