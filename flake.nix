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

      colmena = {
        meta = {
          nixpkgs = import nixpkgs { inherit system; };

          nodeSpecialArgs = {
            unraid-nixos-01 = {
              meta = {
                hostname = "unraid-nixos-01";
                user = "thamenato";
              };
            };
          };
        };

        defaults = {
          imports = [
            inputs.disko.nixosModules.disko
            inputs.sops-nix.nixosModules.sops
          ];
          deployment.buildOnTarget = true;
        };

        unraid-nixos-01 = {
          imports = [ ./nixos/vms/unraid-nixos-01 ];

          deployment = {
            targetHost = "10.0.10.3";
            targetUser = "thamenato";
            tags = [
              "unraid"
              "vm"
            ];
          };
        };
      };
    };
}
