{
  pkgs ? import <nixpkgs> { },
  ...
}:
let
  inherit (pkgs.lib) filterAttrs isDerivation packagesFromDirectoryRecursive;

  zpkgs = packagesFromDirectoryRecursive {
    inherit (pkgs) callPackage newScope;
    directory = ./.;
  };
in
  # only keep attrs that are derivations, since we don't use namespaces
  # (also exclude the `default` attr immediately, which is this
  # expression, which would cause infinite recursion)
  filterAttrs (name: val: name != "default" && isDerivation val) zpkgs
