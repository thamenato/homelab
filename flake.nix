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
    pre-commit-hooks.url = "github:cachix/pre-commit-hooks.nix";
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
      checks =
        {
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
        }
        //
        # from deploy-rs: this is highly advised, and will prevent many possible mistakes
        builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;

      devShells.${system}.default = pkgs.mkShell {
        inherit (self.checks.pre-commit-check) shellHook;

        buildInputs = [
          self.checks.pre-commit-check.enabledPackages
          pkgs.deploy-rs
        ];

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
    };
}
