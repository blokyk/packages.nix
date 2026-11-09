{ lib, ... }:
let
  inherit (lib) mkOption;
  inherit (lib.types) either enum int ints nullOr str submodule;

  consts = import ../option-enums.nix;

  color = either int (enum consts.colors);
in
{
  options = {
    command-execution-time = mkOption {
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

          threshold = mkOption {
            type = ints.unsigned;
            default = 3;
            example = 10;
            description = ''
              Show duration of the last command if takes at least this many seconds.
            '';
          };

          precision = mkOption {
            type = ints.unsigned;
            default = 0;
            example = 3;
            description = ''
              Show this many fractional digits. Zero means round to seconds.
            '';
          };

          format = mkOption {
            type = str;
            default = "d h m s";
            example = "H:M:S";
            description = ''
              Duration format: 1d 2h 3m 4s.

              Note: Looking at the p10k code, it seems like only 'H:M:S' is supported as an alternative format, falling to 'd h m s' otherwise...
            '';
          };

          prefix = mkOption {
            type = nullOr str;
            default = null;
            example = "%ftook ";
            description = ''
              Custom prefix.
            '';
          };

          expression = mkOption {
            type = str;
            default = "$P9K_CONTENT";
            example = "repo: $P9K_CONTENT";
            description = ''
              The expression to use for the element, where $P9K_CONTENT contains
              the status text. See p10k's docs for allowed escape sequences.

              Tip for nix-shell: set this to the empty string to hide the 'pure'/'impure' text (and only show the icon).
            '';
          };

          icon = mkOption {
            type = str;
            default = "$P9K_VISUAL_IDENTIFIER";
            example = "\${icons[EXECUTION_TIME_ICON]}";
          };
        };
      };
    };
  };
}
