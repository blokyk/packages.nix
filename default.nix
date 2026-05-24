{
  pkgs ? import <nixpkgs> { },
  ...
}:
{
  # we don't import modules here, since they have either nixos-specific or
  # home-manager specific config,
  #imports = [ ./modules ./hm-modules ];

  pkgs = pkgs.callPackage ./pkgs { };
}
