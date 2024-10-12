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
    pre-commit-hooks.url = "github:cachix/pre-commit-hooks.nix";
  };

  outputs =
    { self, nixpkgs, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
    in
    {
      checks = {
        pre-commit-check = inputs.pre-commit-hooks.lib.${system}.run {
          src = ./.;
          hooks = {
            check-added-large-files.enable = true;
            check-yaml.enable = true;
            # deadnix.enable = true;
            detect-private-keys.enable = true;
            end-of-file-fixer.enable = true;
            nixfmt-rfc-style.enable = true;
            trim-trailing-whitespace.enable = true;
          };
        };
      };

      devShells.${system}.default = pkgs.mkShell {
        inherit (self.checks.pre-commit-check) shellHook;

        buildInputs = [ self.checks.pre-commit-check.enabledPackages ];

        packages = with pkgs; [
          age
          colmena
          just
          nil
          nixfmt-rfc-style
          sops
        ];
      };

      nixosConfigurations =
        let
          mkMeta =
            {
              user ? "thamenato",
              hostname,
            }:
            {
              user = user;
              hostname = hostname;
            };

          modulesDefaults = [
            inputs.disko.nixosModules.disko
            inputs.sops-nix.nixosModules.sops
          ];

        in
        {
          bastion-proxy = nixpkgs.lib.nixosSystem {
            specialArgs = {
              meta = mkMeta { hostname = "bastion-proxy"; };
            };

            modules = [ ./nixos/vms/hosts/bastion-proxy ] ++ modulesDefaults;
          };

          unraid-nixos-01 = nixpkgs.lib.nixosSystem {
            specialArgs = {
              meta = mkMeta { hostname = "unraid-nixos-01"; };
            };

            modules = [ ./nixos/vms/hosts/unraid-nixos-01 ] ++ modulesDefaults;
          };
        };

      colmena =
        let
          conf = self.nixosConfigurations;
        in
        {
          meta = {
            nixpkgs = import nixpkgs { inherit system; };
            nodeSpecialArgs = builtins.mapAttrs (name: value: value._module.specialArgs) conf;
          };

          defaults = {
            imports = [
              inputs.disko.nixosModules.disko
              inputs.sops-nix.nixosModules.sops
            ];
            deployment = {
              buildOnTarget = true;
              targetUser = "thamenato";
            };
          };

          bastion-proxy = {
            imports = [ ./nixos/vms/hosts/bastion-proxy ];
            deployment = {
              targetHost = "10.0.10.5";
              tags = [
                "vm"
                "bastion"
              ];
            };
          };

          unraid-nixos-01 = {
            imports = [ ./nixos/vms/hosts/unraid-nixos-01 ];

            deployment = {
              targetHost = "10.0.10.3";
              targetUser = "thamenato";
              tags = [
                "vm"
                "apps"
              ];
            };
          };
        };
    };
}
