{
  description = "Homelab NixOS Flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    # disko
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    # For accessing `deploy-rs`'s utility Nix functions
    deploy-rs.url = "github:serokell/deploy-rs";
  };

  outputs = { self, nixpkgs, disko, deploy-rs, ... }@inputs:
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

      deploy.nodes.unraid-nixos = {
        hostname = "10.0.10.208";
        profiles.system = {
          user = "root";
          path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.unraid-nixos;
        };
      };

      # This is highly advised, and will prevent many possible mistakes
      checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
    };
}
