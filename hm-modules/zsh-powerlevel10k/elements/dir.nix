{ lib, ... }:
let
  inherit (lib) mkOption;
  inherit (lib.types) bool either enum int ints nullOr str submodule;

  consts = import ../option-enums.nix;

  color = either int (enum consts.colors);
in
{
  options = {
    dir = mkOption {
      description = "current working directory";
      default = { };
      type = submodule {
        options = {
          # POWERLEVEL9K_DIR_BACKGROUND
          background = mkOption {
            type = nullOr color;
            default = null;
            example = "yellow";
            description = "The background color of this segment, as an xterm color id or name";
          };

          # POWERLEVEL9K_DIR_FOREGROUND
          foreground = mkOption {
            type = color;
            default = "cyan";
            example = "purple";
            description = "The color of the current directory text, as an xterm color id or name";
          };

          shorten = mkOption {
            description = ''
              If the directory is too long, shorten some of its segments, using
              the specified strategy. The shortened directory can be
              tab-completed to the original.
            '';
            default = { };
            type = submodule {
              options = {
                # POWERLEVEL9K_SHORTEN_STRATEGY
                strategy = mkOption {
                  type = enum [
                    "none"
                    "truncate_absolute"
                    "truncate_absolute_chars"
                    "truncate_with_package_name"
                    "truncate_middle"
                    "truncate_from_right"
                    "truncate_to_last"
                    "truncate_to_first_and_last"
                    "truncate_with_folder_marker"
                  ];
                  default = "none";
                  example = "truncate_to_last";
                  description = "The strategy to use to shorten the current directory path";
                };

                # POWERLEVEL9K_SHORTEN_DELIMITER
                delimiter = mkOption {
                  type = str;
                  default = "";
                  example = "-";
                  description = "Replace removed segment suffixes with this symbol";
                };

                # POWERLEVEL9K_SHORTEN_DIR_LENGTH
                length = mkOption {
                  type = ints.positive;
                  default = 1;
                  example = 3;
                  description = "The minimum length each path segment can be shortened to";
                };
              };
            };
          };

          # POWERLEVEL9K_DIR_PATH_ABSOLUTE
          absolute = mkOption {
            type = bool;
            default = false;
            example = true;
            description = "Whether the full absolute path should be displayed";
          };

          # POWERLEVEL9K_DIR_SHOW_WRITABLE
          writable = mkOption {
            type = bool;
            default = false;
            example = true;
            description = "Display an indicator of whether or not the current directory is writable";
          };

          # POWERLEVEL9K_DIR_CONTENT_EXPANSION
          expression = mkOption {
            type = str;
            default = "$P9K_CONTENT";
            example = "currently in %B$P9K_CONTENT%b";
            description = ''
              The expression to use for the element, where $P9K_CONTENT contains
              the final path. See p10k's docs for allowed escape sequences.
            '';
          };
        };
      };
    };
  };
}
