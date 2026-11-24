{ lib, p10k-utils, ... }:
let
  inherit (lib) mkOption;
  inherit (lib.types) ints nullOr str;

  inherit (p10k-utils) genPromptOpts mkElementOption;
in
{
  options = {
    command-execution-time = mkElementOption {
      description = "last command's execution time";
      module = {
        options = {
          threshold = mkOption {
            type = ints.unsigned;
            default = 3;
            example = 10;
            description = ''
              Show duration of the last command if it takes at least this many seconds.
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

          icon = mkOption {
            type = str;
            default = "$P9K_VISUAL_IDENTIFIER";
            example = "\${icons[EXECUTION_TIME_ICON]}";
          };
        };
      };
    };
  };

  config.themeContent = genPromptOpts "command-execution-time" (opts: {
    # we can't just give `opts` directly because it also contains e.g. `expression` and `icon`
    inherit (opts) threshold precision format prefix;
  }) "";
}
