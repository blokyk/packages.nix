let pins = import ./pins {}; in
{
  pkgs ? import pins.nixpkgs {}
}:
let
  inherit (pkgs.lib) packagesFromDirectoryRecursive;

  zpkgs = packagesFromDirectoryRecursive {
    inherit (pkgs) newScope;
    callPackage = throw "nope, turns out this is actually never called";

    directory = builtins.path {
      path = ./.;
      filter = path: type:
        let filename = baseNameOf path; in
        # copy the npins directory completely intact
        baseNameOf (dirOf path) == "pins" || (
          # otherwise...

          # don't copy any `default.nix` files; this is mainly to
          # avoid *this* file from being imported, causing inf-rec
          filename != "default.nix" &&

          # don't import anything that is a symlink, so we avoid ending
          # up with leftover `result/` symlinks polluting things
          type != "symlink"
        );
      recursive = true;
    };
  };
in
  removeAttrs zpkgs [ "pins" ]
