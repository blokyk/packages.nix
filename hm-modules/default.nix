{ ... }:
let
  exceptions = [
    # we don't want to import it by default because it isn't a normal module
    "mk-keybindings"
  ];

  inherit (builtins) attrNames elem filter readDir;
  filterAttrs = pred: set: removeAttrs set (filter (name: !pred name set.${name}) (attrNames set));

  # function to get all (non-recursive) sub folders of a given Path
  listDirectories =
    path:
    let
      dirEntries = attrNames (
        filterAttrs
          (entry: kind: !(elem entry exceptions) && kind == "directory")
          (readDir path)
      );
    in
    map (subpath: path + ("/" + subpath)) dirEntries;
in {
  imports = listDirectories ./.;
}
