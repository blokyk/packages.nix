let
  pkgs = import <nixpkgs> {};
in {
  hostrr = import ./hostrr pkgs;
}