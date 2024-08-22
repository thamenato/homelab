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
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };

      default_user = "thamenato";

      nodes = [
        {
          hostname = "unraid-node-01";
          user = default_user;
          ip = "10.0.10.233";
          modules = [ ./vms/unraid-nodes ];
        }
        {
          hostname = "unraid-node-02";
          user = default_user;
          ip = "10.0.10.111";
          modules = [ ./vms/unraid-nodes ];
        }
        {
          hostname = "unraid-node-03";
          user = default_user;
          ip = "10.0.10.168";
          modules = [ ./vms/unraid-nodes ];
        }
      ];
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        buildInputs = [ pkgs.deploy-rs ];
        packages = with pkgs; [
          nixpkgs-fmt
        ];
      };

      nixosConfigurations = builtins.listToAttrs
        (map
          (host:
            {
              name = host.hostname;
              value = nixpkgs.lib.nixosSystem {
                inherit system;

                specialArgs = {
                  meta = host;
                };

                modules = [
                  disko.nixosModules.disko
                ] ++ host.modules;
              };
            })
          nodes);

      deploy.nodes = builtins.listToAttrs
        (map
          (host:
            {
              name = host.hostname;
              value = {
                hostname = host.ip;
                sshOpts = [ "-i" "~/.ssh/rlyeh" ];
                profiles.system = {
                  user = "root";
                  path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.${host.hostname};
                };
              };
            })
          nodes);

      # This is highly advised, and will prevent many possible mistakes
      checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
    };
}
