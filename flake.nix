{
  description = "Homelab NixOS Flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    # disko
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, disko, ... }@inputs:
    let
      nodes = [
        "unraid-nixos"
      ];
    in
    {
      nixosConfigurations = builtins.listToAttrs
        (map
          (name:
            {
              name = name;
              value = nixpkgs.lib.nixosSystem {
                specialArgs = {
                  meta = { hostname = name; };
                };
                system = "x86_64-linux";
                modules = [
                  disko.nixosModules.disko
                  ./vms/unraid-nixos/hardware-configuration.nix
                  ./vms/unraid-nixos/disko-config.nix
                  ./configuration.nix
                ];
              };
            })
          nodes);
    };
}
