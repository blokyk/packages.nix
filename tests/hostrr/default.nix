{ pkgs, ... }:
let
  withUtils = import ./utils.nix;
in {
  rproxy = {
    simple = pkgs.callPackage (import ./rproxy-simple.nix) withUtils;
  };
  links = {
    on-base = pkgs.callPackage (import ./links-on-base.nix) withUtils;
  };
}