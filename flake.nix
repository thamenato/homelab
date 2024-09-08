{
  description = "Homelab NixOS Flake";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    deploy-rs.url = "github:serokell/deploy-rs";
  };

  outputs =
    {
      self,
      nixpkgs,
      deploy-rs,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };

      default_user = "thamenato";

      nodes = [
        {
          hostname = "unraid-nixos-01";
          user = default_user;
          ip = "10.0.10.3";
          modules = [ ./nixos/vms/unraid-nixos-01 ];
        }
      ];
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        buildInputs = [ pkgs.deploy-rs ];
        packages = with pkgs; [
          age
          nil
          just
          nixfmt-rfc-style
        ];
      };

      nixosConfigurations = builtins.listToAttrs (
        map (host: {
          name = host.hostname;
          value = nixpkgs.lib.nixosSystem {
            inherit system;

            specialArgs = {
              meta = host;
            };

            modules = [
              inputs.disko.nixosModules.disko
              inputs.sops-nix.nixosModules.sops
            ] ++ host.modules;
          };
        }) nodes
      );

      deploy.nodes = builtins.listToAttrs (
        map (host: {
          name = host.hostname;
          value = {
            hostname = host.ip;
            sshOpts = [
              "-i"
              "~/.ssh/rlyeh"
            ];
            profiles.system = {
              user = "root";
              path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.${host.hostname};
            };
          };
        }) nodes
      );

      # This is highly advised, and will prevent many possible mistakes
      checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
    };
}
