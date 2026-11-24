{ config, lib, p10k-utils, ... }:
let
  inherit (lib) attrNames mkOption;

  consts = import ./option-enums.nix;

  # list of prompt elements (or at least, the ones with options)
  prompt-elements = attrNames (
    removeAttrs config [
      "_modules"
      "mode"
      "left-prompt"
      "right-prompt"
      "instant-prompt"
      "hot-reload"
      "background"
      "whitespace"
      "subsegment-separator"
      "segment-separator"
      "icons-expression"
      "themeContent"
    ]
  );
in {
  _module.args.p10k-utils = rec {
    types = {
      color = with lib.types; either int (enum p10k-utils.colors);
      prompt-element = lib.types.enum (consts.prompt-elements ++ prompt-elements);
      p10k-mode = lib.types.enum consts.p10k-modes;
    };

    # the built-in colors, but these can be modified by the user (by overriding this value)
    colors = consts.colors;

    mkLeftRightOption =
      {
        type,
        default ? null,
        example ? null,
        description ? null,
      }:
      mkOption {
        type = lib.types.either type (
          lib.types.submodule {
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
          }
        );
        default = default;
        example = example;
        description = description;
      };

    # takes care of the common foreground/background/expression
    mkElementOption = {
      description,
      module,
      default ? { },
      example ? null
    }:
    lib.mkOption {
      inherit default example;
      description = description.element or description;

      type = lib.types.submoduleWith {
        modules = [
          module
          {
            options = {
              background = mkOption {
                type = lib.types.nullOr types.color;
                default = null;
                example = "yellow";
                description = description.background or
                  "The background color of this segment, as an xterm color id or name";
              };

              foreground = mkOption {
                type = lib.types.nullOr types.color;
                default = null;
                example = "magenta";
                description = description.foreground or
                  "The color of this segment's text, as an xterm color id or name";
              };

              expression = mkOption {
                type = lib.types.str;
                default = "$P9K_CONTENT";
                example = "repo: $P9K_CONTENT";
                description = description.expression or ''
                  The expression to use for the element, where $P9K_CONTENT contains ${
                    description.expressionContent or "the ${description.element or description}"
                  }.
                  See p10k's docs for allowed escape sequences.
                '';
              };

              loading-foreground = mkOption {
                type = lib.types.nullOr types.color;
                default = "grey58";
                example = "red";
                description = "The color of this segment's text when the element is still loading, as an xterm color id or name";
              };

              loading-expression = mkOption {
                type = lib.types.str;
                default = "$P9K_CONTENT";
                description = ''
                  The expression to use for the element when the element is still loading, if applicable.
                  See p10k's docs for allowed escape sequences.
                '';
              };

              icon = mkOption {
                type = lib.types.nullOr lib.types.str;
                default = "$P9K_VISUAL_IDENTIFIER";
                example = "\${icons[NIX_SHELL_ICON]}";
              };
            };
          }
        ];
      };
    };

    isSegmentEnabled = name: (lib.elem name config.left-prompt) || (lib.elem name config.right-prompt);

    # note: if a value is null, it will just not set the option at all; use "" to set an option to null
    optsToTypeset = prefix: lib.concatMapAttrsStringSep "" (
      nixName: value:
      let p10kName = lib.replaceString "-" "_" nixName; in
      if value == null then
        ""
      # if this is an attrset, recurse with the name of the attrset as the prefix
      else if lib.isAttrs value then
        optsToTypeset "${prefix}_${p10kName}" value
      else
        "\ntypeset -g POWERLEVEL9K_${lib.toUpper prefix}_${lib.toUpper p10kName}='${toString value}'"
    );

    appearancePrelude = prefix: opts: optsToTypeset prefix {
      FOREGROUND = opts.foreground or null;
      BACKGROUND = opts.background or null;
      CONTENT_EXPANSION = opts.expression or null;
      VISUAL_IDENTIFIER_EXPANSION = opts.icon or null;
      LOADING_FOREGROUND = opts.loading-foreground or null;
      LOADING_CONTENT_EXPANSION = opts.loading-expression or null;
    };

    # :: String -> (AttrSet -> String) -> (String | (AttrSet -> String)) -> String
    genPromptOpts = name: mapping: extra:
      let prefix = lib.replaceString "-" "_" name; in
      if isSegmentEnabled name then ''
        ${appearancePrelude prefix config.${name}}
        ${optsToTypeset prefix (mapping config.${name})}
        ${if lib.isFunction extra then (extra config.${name}) else extra}
      '' else "";
  };
}
