{ pkgs, meta, ... }:
{
  imports = [
    ./disko-config.nix
    ./hardware-configuration.nix
  ];

  # nix = {
  #   package = pkgs.nixVersions.nix_2_23;
  #   settings = {
  #     experimental-features = [ "nix-command" "flakes" ];
  #     allowed-users = [ meta.user ];
  #     trusted-users = [ meta.user ];
  #   };
  # };

  # # localization
  # time.timeZone = "America/New_York";
  # i18n.defaultLocale = "en_US.UTF-8";
  # i18n.extraLocaleSettings = {
  #   LC_ADDRESS = "en_US.UTF-8";
  #   LC_IDENTIFICATION = "en_US.UTF-8";
  #   LC_MEASUREMENT = "en_US.UTF-8";
  #   LC_MONETARY = "en_US.UTF-8";
  #   LC_NAME = "en_US.UTF-8";
  #   LC_NUMERIC = "en_US.UTF-8";
  #   LC_PAPER = "en_US.UTF-8";
  #   LC_TELEPHONE = "en_US.UTF-8";
  #   LC_TIME = "en_US.UTF-8";
  # };
  # console.keyMap = "us-acentos";

  # # Use the systemd-boot EFI boot loader.
  # boot.loader.systemd-boot.enable = true;
  # boot.loader.efi.canTouchEfiVariables = true;
  # boot.growPartition = true;

  # # basic packages
  # environment.systemPackages = with pkgs; [
  #   git
  #   neovim
  #   htop
  # ];

  services.qemuGuest.enable = true;

  # allow user in group wheel to auth w/o passwd
  # this setting fixes nix-rebuild / deploy-rs issues
  # when building a new generation
  security.sudo.wheelNeedsPassword = false;
}
