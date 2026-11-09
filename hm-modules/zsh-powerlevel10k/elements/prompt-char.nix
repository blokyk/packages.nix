{ lib, ... }:
let
  inherit (lib) mkOption;
  inherit (lib.types) either enum int nullOr str submodule;

  consts = import ../option-enums.nix;

  color = either int (enum consts.colors);
in
{
  options = {
    prompt-char = mkOption {
      description = "multi-functional prompt symbol; changes depending on vi mode: ❯, ❮, V, ▶ for insert, command, visual and replace mode respectively; turns red on error";
      default = { };
      type = submodule {
        options = {
          # POWERLEVEL9K_PROMPT_CHAR_BACKGROUND
          background = mkOption {
            type = nullOr color;
            example = "slateblue";
            description = "The background color of this segment, as an xterm color id or name";
          };

          # POWERLEVEL9K_PROMPT_CHAR_CONTENT_EXPANSION
          symbol = mkOption {
            type = str;
            defaultText = "depends on {option}`theme.mode`";
            example = "%B➜%b";
            description = ''
              The prompt symbol to use. Refer to p10k's docs to see how this
              string is expanded, as well as the allowed sequences.
            '';
          };

          ok = mkOption {
            # todo: support vi modes
            description = "The prompt's style after a successful command";
            default = { };
            type = submodule {
              options = {
                # POWERLEVEL9K_PROMPT_CHAR_OK_{VIINS,VICMD,VIVIS}_FOREGROUND
                foreground = mkOption {
                  type = color;
                  default = "green";
                  example = "cyan";
                  description = "The color of the prompt char after a successful command";
                };
              };
            };
          };

          error = mkOption {
            description = "The prompt's style after a successful command";
            default = { };
            # todo: support vi modes
            type = submodule {
              options = {
                # POWERLEVEL9K_PROMPT_CHAR_ERROR_{VIINS,VICMD,VIVIS}_FOREGROUND
                foreground = mkOption {
                  type = color;
                  default = "red";
                  example = "purple";
                  description = "The color of the prompt char after a successful command, as an xterm color id or name";
                };
              };
            };
          };
        };
      };
    };
  };
}
