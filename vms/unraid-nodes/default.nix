{
  imports = [
    ./configuration.nix
    ./disko-config.nix
    ./hardware-configuration.nix
    # services
    # ../../services/blocky.nix
    ../../services/k3s.nix
  ];
}
