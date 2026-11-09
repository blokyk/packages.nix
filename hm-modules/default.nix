{ ... }:
let
  inherit (import ../utils.nix) listDirectories;
in {
  imports = listDirectories {
    path = ./.;
    exceptions = [
      # we don't want to import it by default because it isn't a normal module
      "mk-keybindings"
    ];
  };
}
