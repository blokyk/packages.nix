{
  pkgs ? import <nixpkgs> {},
  ...
}:
let
  newpkgs = pkgs.extend (import ../maintainers.nix);
  inherit (newpkgs) lib;
in
with lib; let
  # function to get all (non-recursive) sub folders of a given Path
  listDirectories = dirPath:
    let
      dirEntries = attrNames (
        filterAttrs
          (entry: kind: kind == "directory")
          (builtins.readDir dirPath)
      );
    in
      map (path.append dirPath) dirEntries;
in
  # create an attr set like { foo = callPackage ./foo {}; bar = callPackage ./bar {}; }
  # (where `foo` and `bar` are subfolders of this one)
  genAttrs'
    (listDirectories ./.)
    (pkgDir: nameValuePair
      (toString (baseNameOf pkgDir)) # foo =
      (newpkgs.callPackage pkgDir {}) # callPackage ./foo {}
    )