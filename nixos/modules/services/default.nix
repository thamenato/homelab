{ lib, ... }:

with lib;

let
  servicesPath = ./.;
in
{
  # Read all directories from systemModules
  imports = builtins.filter (module: lib.pathIsDirectory module) (
    map (module: "${servicesPath}/${module}") (builtins.attrNames (builtins.readDir servicesPath))
  );

  options = {
    homelab.modules.services.dataDir = mkOption {
      type = types.str;
      default = "/mnt/data";
      description = "The path of the storage.";
    };
  };
}
