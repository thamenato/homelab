{ config, lib, pkgs, meta, ... }:

{
  imports = [ ];

  nix = {
    package = pkgs.nixVersions.nix_2_23;
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      allowed-users = [ "thamenato" ];
      trusted-users = [ "thamenato" ];
    };
  };

  # set zsh as default shell
  environment.shells = with pkgs; [ zsh ];
  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = meta.hostname; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true; # Easiest to use and most distros use this by default.

  # localization
  time.timeZone = "America/New_York";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };
  console.keyMap = "us-acentos";

  users.users.thamenato = {
    isNormalUser = true;
    description = "Thales Menato";
    extraGroups = [ "wheel" ];
    packages = with pkgs; [ ];

    # created using mkpasswd
    hashedPassword = "$6$U/Gk7/zD4uUWVGzJ$CJ6ZKPLpBCUUVzmwsRlv2csJbIuChM8pf1mlRIdazdQBvQyCS3uukcKwH0t20WqJKmDOdQB2N5.qc5TYbKwn01";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGnbZosCtInrhlAvKxwwDITIRqwGcCsCuR8E2FA4dwKh thamenato@kassogtha"
    ];
  };

  security.sudo.wheelNeedsPassword = false;
  environment.systemPackages = with pkgs; [
    git
    neovim
    htop
  ];

  # Enable the OpenSSH daemon
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
  };

  services.qemuGuest.enable = true;

  system.stateVersion = "24.05";
}
