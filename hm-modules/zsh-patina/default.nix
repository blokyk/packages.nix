{ config, lib, pkgs, ... }:
let
  inherit (lib) mkEnableOption mkOption types;

  renameAttrs = renames:
    lib.mapAttrs' (attr: val:
      let name = renames.${attr} or attr; in
      if lib.isString name || !lib.isAttrs val then
        { inherit name; value = val; }
      else
        assert lib.isAttrs name;
        { name = attr; value = renameAttrs name val; }
    );

  # {
  #   "keyword" = "purple"
  #   "dynamic.path" = { foreground = "green"; }
  #   "dynamic.path.file.complete" = { foreground = "green"; underline = true; }
  # }
  themeType =
    let
      colorType = types.oneOf [
        (types.enum [ "black" "red" "green" "yellow" "blue" "magenta" "cyan" "white" ])
        types.ints.u8
        (lib.types.strMatching "#([0-9a-f][0-9a-f][0-9a-f]){1,2}")
      ];

      # { foreground = "blue"; background = "white"; bold = true; underline = false; }
      styleType = types.submodule {
        options = {
          foreground = mkOption {
            type = types.nullOr colorType;
            example = "magenta";
          };

          background = mkOption {
            type = types.nullOr colorType;
            example = "black";
          };

          bold = mkOption {
            type = types.nullOr types.bool;
            example = true;
          };

          underlined = mkOption {
            type = types.nullOr types.bool;
            example = true;
          };
        };
      };
    in
      types.attrsOf (
        types.coercedTo
          colorType
          (color: { foreground = color; })
          styleType
      );

  # { callables = true; paths = "complete"; }
  dynamicType = types.submodule {
    options = {
      callables = mkOption {
        type = types.bool;
        default = true;
      };

      paths = mkOption {
        type = types.enum ["none" "partial" "complete"];
        default = "complete";
        description = ''
          "none"     - disable dynamic highlighting for paths
          "partial"  - dynamically highlight paths even if only a prefix has been
                        entered
          "complete" - dynamically highlight paths only if they have been entered
                        completely (default)
        '';
      };
    };
  };

  precmdType =
    let
      modeType = types.enum [ "default" "argument" ];
    in
      types.submodule {
      options = {
        mode = mkOption {
          type = types.enum [ "default" "argument" ];
          default = "default";
          description = ''
            Controls how the word following the precommand's options is highlighted.

            "default"   - the next word is treated as a callable -- a command, alias,
                          function, or builtin -- and highlighting continues from there.
                          Use this for precommands like `sudo` or `env` that prefix
                          another command.

            "arguments" - the remaining words are treated as plain arguments rather than a
                          callable. Use this for precommands like `sudoedit` that take
                          file names.
          '';
        };

        options = mkOption {
          type = types.listOf (types.submodule {
            options = {
              short = mkOption {
                type = types.nullOr types.str;
                example = "u";
                description = ''
                  The short flag without the leading dash.
                '';
              };

              long = mkOption {
                type = types.nullOr types.str;
                example = "user";
                description = ''
                  The long flag without leading dashes.
                '';
              };

              arg = mkOption {
                type = types.enum [ "required" "optional" "none" ];
                default = "required";
                description = ''
                  Controls whether the option takes an argument:
                    "required" (default) - the option must be followed by an argument
                    "optional"           - the option may be followed by an argument
                    "none"               - the option takes no argument
                '';
              };

              switch_to_mode = mkOption {
                type = types.nullOr modeType;
                description = ''
                  If set to "arguments", the remaining words after this option are treated as plain arguments.
                  Useful for options like sudo's -e/--edit, which causes it to behave like sudoedit.
                '';
              };
            };
          });
        };
      };
  };

  zpkgs = import ../../pkgs {};
in {
  options.programs.zsh.patina = {
    enable = mkEnableOption "zsh-patina, a blazingly fast Zsh syntax highlighter";
    package = lib.mkPackageOption zpkgs "zsh-patina" { pkgsText = "<zoeee/pkgs>"; };

    settings = {
      theme = mkOption {
        type = types.either types.str themeType;
        default = "patina";
        description = ''
          Either a string for one of the builtin themes, such as `"classic"`,
          or a full custom theme description structured as an attribute set
          (see [the upstream docs](https://github.com/michel-kraemer/zsh-patina#creating-a-custom-theme) to create you own theme).
        '';
        example = ''
          # fixme
        '';
      };

      dynamic = mkOption {
        type = types.either types.bool dynamicType;
        default = true;
        description = ''
          Enable or disable dynamic highlighting.
        '';
      };

      max-line-length = mkOption {
        type = types.ints.positive;
        default = 20000;
        example = 500;
        description = ''
          For performance reasons, highlighting is disabled for very long lines. This
          option specifies the maximum length of a line (in bytes) up to which
          highlighting is applied.
        '';
      };

      timeout = mkOption {
        type = lib.types.ints.positive;
        default = 500;
        example = 250;
        description = ''
          The maximum time (in milliseconds) to spend on highlighting a command. If
          highlighting takes longer, it will be aborted and the command will be
          partially highlighted.

          Note that the timeout only applies to multi-line commands. Highlighting cannot
          be aborted in the middle of a line. If you often deal with long lines that
          take longer to highlight than the timeout, consider reducing {opt}`programs.zsh.patina.settings.max-line-length`.
        '';
      };

      precommands = mkOption {
        type = types.attrsOf precmdType;
        default = { };
        description = ''
          A precommand is a command that prefixes another command or a list of arguments, causing zsh-patina to highlight what follows accordingly
        '';
      };
    };
  };

  config =
    let
      cfg = config.programs.zsh.patina;

      settings = lib.pipe cfg.settings [
        # rename attributes with a different case
        (renameAttrs {
          max-line-length = "max_line_length";
          timeout = "timeout_ms";
        })

        # transform precommands from
        #   { foo = { ... }; }
        # to
        #   [ { name = "foo"; ... } ]
        (cfg: (removeAttrs cfg ["precommands"]) // (
          if (cfg.precommands or {}) != {} then
            { precommands = lib.mapAttrsToList
              (name: val: { inherit name; } // val)
              cfg.precommands;
            }
          else {}
        ))
      ];

      patina-conf =
        (pkgs.formats.toml {}).generate
          "config.toml"
          # add `highlighting` global scope
          { highlighting = settings; };

      patina-exe = lib.getExe cfg.package;
    in {
      home.activation = lib.mkIf cfg.enable {
        # restart the zsh-patina daemon so that config changes are taken into account
        myActivationAction = lib.hm.dag.entryAfter ["onFilesChange"] ''
          ZSH_PATINA_CONFIG_PATH="${patina-conf}" run ${patina-exe} restart
        '';
      };

      programs.zsh.initContent = lib.mkIf cfg.enable (
        lib.mkOrder 1200 ''
          export ZSH_PATINA_CONFIG_PATH="${patina-conf}"
          eval "$(${patina-exe} activate)"
          eval "$(${patina-exe} completion)"
        ''
      );
    };
}
