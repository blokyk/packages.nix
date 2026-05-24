let pins = import ./npins {}; in
{
  pkgs ? import pins.nixpkgs {}
}:
{
  pkgs = pkgs.callPackage ./pkgs { };
}
