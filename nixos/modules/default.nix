{ lib, ... }:
let
  currPath = ./.;
in
{
  imports = builtins.filter (module: lib.pathIsDirectory module) (
    map (module: "${currPath}/${module}") (builtins.attrNames (builtins.readDir currPath))
  );
}
