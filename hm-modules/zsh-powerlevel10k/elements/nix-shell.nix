{ lib, ... }:
let
  inherit (lib) mkOption;
  inherit (lib.types) bool either enum int nullOr str submodule;

  consts = import ../option-enums.nix;

  color = either int (enum consts.colors);
in
{
  options = {
    nix-shell = mkOption {
      type = submodule {
        options = {
          background = mkOption {
            type = nullOr color;
            default = null;
            example = "yellow";
            description = "The background color of this segment, as an xterm color id or name";
          };

          foreground = mkOption {
            type = nullOr color;
            default = null;
            example = "magenta";
            description = "The color of this segment's text, as an xterm color id or name";
          };

          infer-from-path = mkOption {
            type = bool;
            default = false;
            example = true;
            description = "Treat current shell as a nix-shell if PATH contains a subdirectory of /nix/store";
          };

          expression = mkOption {
            type = nullOr str;
            example = "repo: %B$P9K_CONTENT%b";
            description = ''
              The expression to use for the element, where $P9K_CONTENT contains
              the status text. See p10k's docs for allowed escape sequences.

              Tip for nix-shell: set this to the empty string to hide the 'pure'/'impure' text (and only show the icon).
            '';
          };

          icon = mkOption {
            type = nullOr str;
            default = "$P9K_VISUAL_IDENTIFIER";
            example = "\${icons[NIX_SHELL_ICON]}";
          };
        };
      };
    };
  };
}
