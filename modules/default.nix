{ ... }:
let
  inherit (import ../utils.nix) listDirectories;
in {
  imports = listDirectories {
    path = ./.;
    exceptions = [];
  };
}
