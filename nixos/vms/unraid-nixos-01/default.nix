{
  imports = [
    ../base
    ./configuration.nix
    ../../services
  ];

  homelab.services = {
    blocky.enable = true;
    paperless.enable = true;
    nextcloud.enable = true;
  };
}
