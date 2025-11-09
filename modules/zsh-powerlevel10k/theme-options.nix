{ lib, config, mkMDList, ... }:
let
  inherit (lib) mkOption types;

  consts = import ./option-enums.nix;

  p10k-mode = types.enum consts.p10k-modes;
  color = lib.types.either (lib.types.int) (lib.types.enum consts.colors);
  prompt-element = types.enum consts.prompt-elements;

  mkLeftRightOption =
    {
      type,
      default ? null,
      example ? null,
      description ? null,
    }:
      (mkOption {
        type = types.either
          type
          (types.submodule {
            option = {
              left = mkOption {
                type = type;
                default = default.left ? default;
                example = example.left ? example;
                description = description.left ? "The value of this option for the left side of the prompt";
              };
              right = mkOption {
                type = type;
                default = default.right ? default;
                example = example.right ? example;
                description = description.left ? "The value of this option for the right side of the prompt";
              };
            };
          });
        default = default;
        example = example;
        description = description;
      });
in
with lib; {
  options = {
    # POWERLEVEL9K_MODE
    mode = mkOption {
      type = p10k-mode;
      example = "nerdfont-complete";
      description = literalMD ''
        The powerlevel10k mode to use. This depends on your terminal
        emulator and installed fonts, and can be determined using the
        'p10k configure' wizard (look for the variable `POWERLEVEL9K_MODE`
        in the generated theme).
      '';
    };

    # POWERLEVEL9K_LEFT_PROMPT_ELEMENTS
    left-prompt = mkOption {
      type = types.listOf prompt-element;
      default = [ "prompt-char" ];
      example = [ "dir" "vcs" "prompt-char" ];
      description = literalMD ''
        The list of prompt elements shown on the **left**. Fill it with the most important segments.

        See the list of elements in [p10k's README](https://github.com/romkatv/powerlevel10k#batteries-included).
      '';
    };

    # POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS
    right-prompt = mkOption {
      type = types.listOf prompt-element;
      default = [ ];
      example = [ "status" "command_execution_time" "time" ];
      description = literalMD ''
        The list of prompt elements shown on the **right**. Fill it with less important segments.
        Right prompt on the last prompt line (where you are typing your commands) gets automatically
        hidden when the input line reaches it. Right prompt above the last prompt line gets hidden
        if it would overlap with left prompt.

        See the list of elements in [p10k's README](https://github.com/romkatv/powerlevel10k#batteries-included).
      '';
    };

    # POWERLEVEL9K_INSTANT_PROMPT
    instant-prompt = mkOption {
      type = types.enum [ "off" "quiet" "verbose" ];
      default = "verbose";
      example = "off";
      description = ''
        Instant prompt mode.
          - off:
              Disable instant prompt. Choose this if you've tried instant prompt and found
              it incompatible with your zsh configuration files.
          - quiet:
              Enable instant prompt and don't print warnings when detecting console output
              during zsh initialization. Choose this if you've read and understood
              https://github.com/romkatv/powerlevel10k#instant-prompt.
          - verbose:
              Enable instant prompt and print a warning when detecting console output during
              zsh initialization. Choose this if you've never tried instant prompt, haven't
              seen the warning, or if you are unsure what this all means.
      '';
    };

    # (inverse of) POWERLEVEL9K_DISABLE_HOT_RELOAD
    hot-reload = mkOption {
      type = types.bool;
      default = false;
      example = true;
      description = ''
        Hot reload allows you to change POWERLEVEL9K options after Powerlevel10k has been initialized.
        For example, you can type POWERLEVEL9K_BACKGROUND=red and see your prompt turn red. Hot reload
        can slow down prompt by 1-2 milliseconds, so it's better to keep it turned off unless you
        really need it.
      '';
    };

    # POWERLEVEL9K_BACKGROUND
    background = mkOption {
      type = types.nullOr color;
      default = null; # transparent
      example = "deeppink4";
      description = literalMD ''
        Background color of the whole prompt, as an xterm color id or name. See
        [the p9k wiki](https://github.com/Powerlevel9k/powerlevel9k/wiki/Stylizing-Your-Prompt#segment-color-customization)
        for more information.
      '';
    };

    # POWERLEVEL9K_{LEFT,RIGHT}_{LEFT,RIGHT}_WHITESPACE
    whitespace = mkOption (
      let
        inner = mkLeftRightOption {
          type = types.str;
          default = "";
          example = "\\t";
          description = {
            left = "The whitespace to put on the left of each element";
            right = "The whitespace to put on the right of each element";
          };
        };
      in {
        description = "The whitespace around each element on each side of the prompt";
        default = "";
        example = "\\t";
        type = types.either inner.type
          (types.submodule {
            options = {
              leftElements = inner // {
                description = "The whitespace to use around each element on the left side of the prompt";
              };

              rightElements = inner // {
                description = "The whitespace to use around each element on the right side of the prompt";
              };
            };
          })
        ;
      }
    );

    # POWERLEVEL9K_{LEFT,RIGHT}_SUBSEGMENT_SEPARATOR=
    subsegment-separator = mkLeftRightOption {
      type = types.str;
      default = " ";
      example = "|";
      description = "String to use to separate segments of the same color";
    };

    # POWERLEVEL9K_{LEFT,RIGHT}_SEGMENT_SEPARATOR=
    segment-separator = mkLeftRightOption {
      type = types.str;
      default = "";
      example = "|";
      description = "String to use to separate (different-color) segments";
    };

    # POWERLEVEL9K_VISUAL_INDICATOR_EXPANSION
    # cf here for more on expression: https://github.com/romkatv/powerlevel10k/issues/367
    icons-expression = mkOption {
      type = types.str;
      default = "";
      example = "-";
    };

    extraConfig = mkOption {
      type = types.lines;
      default = "";
      example = ''
        echo "prompt done!"
      '';
      description = "Extra configuration to append at the end of `p10k.zsh`'s theming function";
    };
  };
}