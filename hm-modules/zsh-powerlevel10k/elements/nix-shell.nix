{ lib, p10k-utils, ... }:
let
  inherit (lib) mkOption;
  inherit (lib.types) bool;

  inherit (p10k-utils) genPromptOpts mkElementOption;
in
{
  options = {
    nix-shell = mkElementOption {
      description = {
        element = "indicates whether the current shell is a nix-shell";
        expression = ''
          The expression to use for the element, where $P9K_CONTENT contains either 'pure', 'impure', or nothing, based on the nix-ness of the current shell.
          See p10k's docs for allowed escape sequences.

          Tip for nix-shell: set this to the empty string to hide the 'pure'/'impure' text (and only show the icon).
        '';
      };
      module = {
        options = {
          infer-from-path = mkOption {
            type = bool;
            default = false;
            example = true;
            description = "Treat current shell as a nix-shell if PATH contains a subdirectory of /nix/store";
          };
        };
      };
    };
  };

  config.themeContent = genPromptOpts "nix-shell" (opts: {
    infer_from_path = lib.boolToString opts.infer-from-path;
  }) "";
}
