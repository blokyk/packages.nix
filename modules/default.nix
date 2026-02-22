{ ... }:
let
  inherit (builtins) attrNames filter readDir;
  filterAttrs = pred: set: removeAttrs set (filter (name: !pred name set.${name}) (attrNames set));

  # function to get all (non-recursive) sub folders of a given Path
  listDirectories =
    path:
    let
      dirEntries = attrNames (
        filterAttrs (entry: kind: kind == "directory") (readDir path)
      );
    in
    map (subpath: path + ("/" + subpath)) dirEntries;
in {
  imports = listDirectories ./.;
}
