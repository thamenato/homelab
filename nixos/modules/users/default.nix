{ lib, config, meta, pkgs, ... }:

with lib;

let
  cfg = config.homelab.modules.users;
in
{
  options = {
    homelab.modules.users.enable = mkEnableOption "Users configuration";
  };

  config = mkIf cfg.enable {
    users.users.${meta.user} = {
      isNormalUser = true;
      extraGroups = [ "wheel" ];
      packages = with pkgs; [ ];

      # created using mkpasswd
      hashedPassword = "$6$U/Gk7/zD4uUWVGzJ$CJ6ZKPLpBCUUVzmwsRlv2csJbIuChM8pf1mlRIdazdQBvQyCS3uukcKwH0t20WqJKmDOdQB2N5.qc5TYbKwn01";
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGnbZosCtInrhlAvKxwwDITIRqwGcCsCuR8E2FA4dwKh thamenato@kassogtha"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM+Xfrcniquxk540pVUPSxSj4vyBrCZbbjmRQkl3dvQX thamenato@zoth-ommog"
      ];
    };
  };
}

