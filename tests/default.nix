let
  pins = import ../npins {};
  pkgs = import pins.nixpkgs {};
in {
  hostrr = pkgs.callPackage ./hostrr { };
  syncyomi = pkgs.callPackage ./syncyomi { };
  z8h = pkgs.callPackage ./z8h { };
}
