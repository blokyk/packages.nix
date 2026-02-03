{
  pkgs ? import <nixpkgs> { },
  ...
}:
let
  newpkgs = pkgs.extend (import ./maintainers.nix).overlay;
in
{
  # we don't import modules here, since they have either nixos-specific or
  # home-manager specific config,
  #imports = [ ./modules ./hm-modules ];

  pkgs = newpkgs.callPackage ./pkgs { };
}
