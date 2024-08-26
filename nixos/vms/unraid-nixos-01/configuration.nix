{ config, pkgs, meta, ... }:

{
  networking.hostName = meta.hostname;
  networking.networkmanager.enable = true;

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

  environment.systemPackages = with pkgs; [ ];

  fileSystems = {
    # mount unraid user share to VM using 9p
    "/mnt/data" = {
      device = "data";
      fsType = "9p";
      options = [
        "rw"
        "relatime"
        "access=client"
        "trans=virtio"
      ];
    };
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

  system.stateVersion = "24.05";
}
