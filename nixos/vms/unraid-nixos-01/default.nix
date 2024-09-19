{ pkgs, meta, ... }:

{
  imports = [
    ../../modules
    ./hardware-configuration.nix
    ./disko-config.nix
  ];

  sops = {
    defaultSopsFile = ../../../secrets/unraid-nixos-01.yaml;
    defaultSopsFormat = "yaml";
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
  };

  networking.hostName = meta.hostname;
  networking.networkmanager.enable = true;

  homelab.modules = {
    boot.enable = true;
    locale.enable = true;
    nix.enable = true;
    programs.systemPackages.enable = true;
    users.enable = true;

    services = {
      blocky.enable = true;
      nginx.enable = true;
      openssh.enable = true;
      paperless.enable = true;
      postgres.enable = true;
    };
  };

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

  services.qemuGuest.enable = true;
  # allow user in group wheel to auth w/o passwd
  # this setting fixes nix-rebuild / deploy-rs issues
  # when building a new generation
  security.sudo.wheelNeedsPassword = false;

  # kernel version
  boot.kernelPackages = pkgs.linuxPackages_6_10;

  system.stateVersion = "24.05";
}
