{ config, lib, pkgs, meta, ... }:

{
  nix = {
    package = pkgs.nixVersions.nix_2_23;
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      allowed-users = [ meta.user ];
      trusted-users = [ meta.user ];
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

  environment.systemPackages = with pkgs; [
    git
    neovim
    htop
  ];

  # allow user in group wheel to auth w/o passwd
  # this setting fixes nix-rebuild / deploy-rs issues
  # when building a new generation
  security.sudo.wheelNeedsPassword = false;

  # Enable the OpenSSH daemon
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
  };

  services.qemuGuest.enable = true;

  fileSystems."/mnt/data" = {
    device = "data";
    fsType = "9p";
    options = [
      "rw"
      "relatime"
      "access=client"
      "trans=virtio"
    ];
  };

  # hardware = {
  #   opengl.enable = true;

  #   nvidia = {
  #     # Modesetting is required.
  #     modesetting.enable = true;
  #     # Use the NVidia open source kernel module (not to be confused with the
  #     # independent third-party "nouveau" open source driver).
  #     open = false;
  #     # Enable the Nvidia settings menu,
  #     # accessible via `nvidia-settings`.
  #     nvidiaSettings = true;
  #     # Optionally, you may need to select the appropriate driver version for your specific GPU.
  #     package = config.boot.kernelPackages.nvidiaPackages.stable;
  #   };
  # };

  # kernel version
  boot.kernelPackages = pkgs.linuxPackages_6_10;
  system.autoUpgrade = {
    enable = true;
    allowReboot = false;
  };

  system.stateVersion = "24.05";
}
