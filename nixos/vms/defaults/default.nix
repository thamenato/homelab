{ meta, pkgs, ... }:
{
  imports = [
    ./disko-config.nix
    ./hardware-configuration.nix
    ../../modules
  ];

  networking.networkmanager.enable = true;
  networking.hostName = meta.hostname;

  homelab.modules = {
    boot.enable = true;
    locale.enable = true;
    nix.enable = true;
    programs.systemPackages.enable = true;
    users.enable = true;
    services.openssh.enable = true;
  };

  services.qemuGuest.enable = true;
  # allow user in group wheel to auth w/o passwd
  # this setting fixes nix-rebuild / deploy-rs issues
  # when building a new generation
  security.sudo.wheelNeedsPassword = false;

  # kernel version
  boot.kernelPackages = pkgs.linuxPackages_6_10;

  system.stateVersion = "24.05";
}
