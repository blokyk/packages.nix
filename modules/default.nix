{ lib, ... }:
let
  # function to get all (non-recursive) sub folders of a given Path
  listDirectories = path:
    let
      dirEntries = lib.attrNames (
        lib.filterAttrs
          (entry: kind: kind == "directory")
          (builtins.readDir path)
      );
    in
      map (lib.path.append path) dirEntries;
in {
  imports = listDirectories ./.;
}