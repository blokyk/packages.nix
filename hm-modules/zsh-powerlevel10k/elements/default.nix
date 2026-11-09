{ ... }:
let
  inherit (import ../../../utils.nix) listNixFilesAndDirs;
in {
  imports = listNixFilesAndDirs {
    path = ./.;
    exceptions = ["default.nix"];
  };
}
