{ lib, p10k-utils, ... }:
let
  inherit (lib) mkOption;
  inherit (lib.types) bool enum ints str submodule;

  inherit (p10k-utils) genPromptOpts mkElementOption optsToTypeset;
in
{
  options = {
    dir = mkElementOption {
      description = {
        element = "current working directory";
        expressionContent = "the final path";
      };
      module = {
        options = {
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
        };
      };
    };
  };

  config.themeContent =
    genPromptOpts "dir" (opts: {
      path_absolute = lib.boolToString opts.absolute;
      show_writable = lib.boolToString opts.writable;
    }) (opts: optsToTypeset "shorten" {
      # for some fucking reason, this is under _SHORTEN directly instead of _DIR_SHORTEN
      inherit (opts.shorten) strategy delimiter;
      dir_length = opts.shorten.length;
    });
}
