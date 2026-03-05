{
  pkgs ? import <nixpkgs> { },
  ...
}:
let
  inherit (pkgs.lib) filterAttrs isDerivation packagesFromDirectoryRecursive;

  newpkgs = pkgs.extend (import ../maintainers.nix).overlay;
  zpkgs = packagesFromDirectoryRecursive {
    inherit (newpkgs) callPackage newScope;
    directory = ./.;
  };
in
  # only keep attrs that are derivations, since we don't use namespaces
  # (also exclude the `default` attr immediately, which is this
  # expression, which would cause infinite recursion)
  filterAttrs (name: val: name != "default" && isDerivation val) zpkgs
