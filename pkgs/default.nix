{
  pkgs ? import <nixpkgs> {},
  ...
}: with pkgs.lib; let
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
in
  # create an attr set like { foo = callPackage ./foo {}; bar = callPackage ./bar {}; }
  # (where `foo` and `bar` are subfolders of this one)
  genAttrs'
    (listDirectories ./.)
    (pkgDir: nameValuePair
      (toString (baseNameOf pkgDir)) # foo =
      (pkgs.callPackage pkgDir {}) # callPackage ./foo {}
    )