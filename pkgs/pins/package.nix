# "oh woe is you zoe! you're too dumb to think about just overriding `callPackage`
# in `pkgs/default.nix`, instead of going through this whole ordeal! what a pity!"
#
# ...yeah, i tried that :/ unfortunately, `newScope` doesn't respect the `callPackage`
# you provide to `packagesFromDirectoryRecursive` (cf nixpkgs#554562), and writing your
# own `newScope` basically requires writing your own splicing logic, so i think i'll sit
# this one out. this way of doing things sucks, but it does seem like the only reasonable
# thing that doesn't involve a shit ton of repetition

{ pkgs }:
let
  pins = import ./default.nix {};
in
# give `pkgs` to every pin, so that pins use nixpkgs fetchers
# instead of eval fetchers, thus avoiding IFD
builtins.mapAttrs (name: pin: pin { inherit pkgs; }) pins
