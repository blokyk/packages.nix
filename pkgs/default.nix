let pins = import ../npins {}; in
{
  pkgs ? import pins.nixpkgs {}
}:
let
  inherit (pkgs.lib) filterAttrs isDerivation packagesFromDirectoryRecursive;

  zpkgs = packagesFromDirectoryRecursive {
    inherit (pkgs) callPackage newScope;
    directory = builtins.path {
      path = ./.;
      filter = path: type:
        let filename = baseNameOf path; in
        filename != "default.nix" && filename != "npins" && type != "symlink";
      recursive = true;
    };
  };
in
  zpkgs
