{ config, lib, p10k-utils, ... }:
let
  inherit (lib) mkOption types;

  inherit (p10k-utils) mkLeftRightOption;
  inherit (p10k-utils.types) color p10k-mode prompt-element;

  baseTheme =
    let
      whitespace-left-prompt =
        let
          ws = config.whitespace;
        in
        if (lib.isString ws) then ws else ws.left-elements;
      whitespace-right-prompt =
        let
          ws = config.whitespace;
        in
        if (lib.isString ws) then ws else ws.right-elements;

      getLeftValue = opt: lib.attrByPath [ "left" ] opt opt;
      getRightValue = opt: lib.attrByPath [ "right" ] opt opt;
    in ''
      # Defines character set used by powerlevel10k. It's best to let `p10k configure` set it for you.
      typeset -g POWERLEVEL9K_MODE=${config.mode}

      # The list of segments shown on the left. Fill it with the most important segments.
      typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(
        ${lib.join " " (map (lib.replaceStrings [ "-" ] [ "_" ]) config.left-prompt)}
      )

      # The list of segments shown on the right. Fill it with less important segments.
      typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(
        ${lib.join " " (map (lib.replaceStrings [ "-" ] [ "_" ]) config.right-prompt)}
      )

      # general prompt background
      typeset -g POWERLEVEL9K_BACKGROUND="${toString config.background}"

      # Spacing around each prompt element; LEFT_RIGHT means left prompt, right side of the element
      typeset -g POWERLEVEL9K_RIGHT_RIGHT_WHITESPACE="${getRightValue whitespace-right-prompt}"
      typeset -g POWERLEVEL9K_RIGHT_LEFT_WHITESPACE="${getLeftValue whitespace-right-prompt}"
      typeset -g POWERLEVEL9K_LEFT_RIGHT_WHITESPACE="${getRightValue whitespace-left-prompt}"
      typeset -g POWERLEVEL9K_LEFT_LEFT_WHITESPACE="${getLeftValue whitespace-left-prompt}"

      # Separator between same-color prompt element
      typeset -g POWERLEVEL9K_RIGHT_SUBSEGMENT_SEPARATOR="${getRightValue config.subsegment-separator}"
      typeset -g POWERLEVEL9K_LEFT_SUBSEGMENT_SEPARATOR="${getLeftValue config.subsegment-separator}"
      # Separator between different-color prompt element
      typeset -g POWERLEVEL9K_RIGHT_SEGMENT_SEPARATOR="${getRightValue config.segment-separator}"
      typeset -g POWERLEVEL9K_LEFT_SEGMENT_SEPARATOR="${getLeftValue config.segment-separator}"

      # General expression to use for displaying prompt icons
      typeset -g POWERLEVEL9K_VISUAL_IDENTIFIER_EXPANSION='${config.icons-expression}'
    '';

  hotReload = ''
    # Hot reload allows you to change POWERLEVEL9K options after Powerlevel10k has been initialized.
    # For example, you can type POWERLEVEL9K_BACKGROUND=red and see your prompt turn red. Hot reload
    # can slow down prompt by 1-2 milliseconds, so it's better to keep it turned off unless you
    # really need it.
    typeset -g POWERLEVEL9K_INSTANT_PROMPT=${toString config.instant-prompt}

    # Hot reload allows you to change POWERLEVEL9K options after Powerlevel10k has been initialized.
    # For example, you can type POWERLEVEL9K_BACKGROUND=red and see your prompt turn red. Hot reload
    # can slow down prompt by 1-2 milliseconds, so it's better to keep it turned off unless you
    # really need it.
    typeset -g POWERLEVEL9K_DISABLE_HOT_RELOAD=${lib.boolToString (!config.hot-reload)}
  '';
in
with lib;
{
  imports = [
    (lib.modules.mkRenamedOptionModule
      [ "extraContent" ]
      [ "themeContent" ]
    )
  ];

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
      example = [
        "dir"
        "vcs"
        "prompt-char"
      ];
      description = literalMD ''
        The list of prompt elements shown on the **left**. Fill it with the most important segments.

        See the list of elements in [p10k's README](https://github.com/romkatv/powerlevel10k#batteries-included).
      '';
    };

    # POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS
    right-prompt = mkOption {
      type = types.listOf prompt-element;
      default = [ ];
      example = [
        "status"
        "command_execution_time"
        "time"
      ];
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
      type = types.enum [
        "off"
        "quiet"
        "verbose"
      ];
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
      in
      {
        description = "The whitespace around each element on each side of the prompt";
        default = "";
        example = "\\t";
        type = types.either inner.type (
          types.submodule {
            options = {
              leftElements = inner // {
                description = "The whitespace to use around each element on the left side of the prompt";
              };

              rightElements = inner // {
                description = "The whitespace to use around each element on the right side of the prompt";
              };
            };
          }
        );
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

    themeContent = mkOption {
      type = types.lines;
      default = "";
      example = ''
        echo "prompt done!" > ~/.p10k.log
      '';
    };
  };

  config = {
    themeContent = lib.mkMerge [
      (lib.mkOrder 0 ''
        emulate -L zsh -o extended_glob

        # Unset all configuration options. This allows you to apply configuration changes without
        # restarting zsh. Edit ~/.p10k.zsh and type `source ~/.p10k.zsh`.
        unset -m '(POWERLEVEL9K_*|DEFAULT_USER)~POWERLEVEL9K_GITSTATUS_DIR'

        # Zsh >= 5.1 is required.
        [[ $ZSH_VERSION == (5.<1->*|<6->.*) ]] || return
      '')

      (lib.mkBefore baseTheme)
      # all your config will go here!
      (lib.mkAfter hotReload)

      # since it reloads the whole config after being set, this definitely needs to be last
      (lib.mkOrder 10000 ''
        # If p10k is already loaded, reload configuration.
        # This works even with POWERLEVEL9K_DISABLE_HOT_RELOAD=true.
        (( ! $+functions[p10k] )) || p10k reload
      '')
    ];
  };
}
