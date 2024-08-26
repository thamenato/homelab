{
  imports = [
    ../base
    ./configuration.nix
    ../../services
  ];

  homelab.services = {
    blocky.enable = true;
    k3s.enable = false;
  };
}
