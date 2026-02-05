{
  pkgs ? import <nixpkgs> { },
  ...
}:
let
  newpkgs = pkgs.extend (import ../maintainers.nix).overlay;
in
newpkgs.lib.packagesFromDirectoryRecursive {
  inherit (newpkgs) callPackage newScope;
  directory = ./.;
}
