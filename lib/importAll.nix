dir:

let
  entries = builtins.readDir dir;

  isModule =
    name:
    name != "default.nix"
    && (
      (entries.${name} == "regular" && builtins.match ".*\\.nix" name != null)
      || (entries.${name} == "directory" && builtins.pathExists (dir + "/${name}/default.nix"))
    );
in
map (name: dir + "/${name}") (builtins.filter isModule (builtins.attrNames entries))
