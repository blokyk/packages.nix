let
  inherit (builtins) attrNames attrValues elem filter mapAttrs readDir stringLength substring;

  filterAttrs = pred: set: removeAttrs set (filter (name: !pred name set.${name}) (attrNames set));
  mapAttrsToList = f: attrs: attrValues (mapAttrs f attrs);
  hasSuffix =
    suffix: content:
    let
      lenSuffix = stringLength suffix;
      lenContent = stringLength content;
    in
      lenContent >= lenSuffix && substring (lenContent - lenSuffix) lenContent content == suffix;

in {
  listDirectories = { path, exceptions ? [] }:
    let
      dirEntries = attrNames (
        filterAttrs
          (entry: kind: !(elem entry exceptions) && kind == "directory")
          (readDir path)
      );
    in
    map (subpath: path + ("/" + subpath)) dirEntries;

  listNixFilesAndDirs = { path, exceptions ? ["default.nix"] }:
    let
      unfilteredEntries = builtins.readDir path;

      nixyEntries = filterAttrs (
        name: type:
          if elem name exceptions then
            false
          else if type == "directory" then
            builtins.pathExists (path + (("/" + name) + "/default.nix"))
          else
            # include all nix files *except* default.nix
            hasSuffix ".nix" name
      ) unfilteredEntries;

      pathsToImport = mapAttrsToList (name: _: path + ("/" + name)) nixyEntries;
    in pathsToImport;

}
