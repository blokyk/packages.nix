{ lib, ... }:
let
  inherit (lib) mkIf mkOption mkOptionDefault;
  inherit (lib.types) bool either enum int ints nullOr str submodule;

  consts = import ./option-enums.nix;

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

    vcs = mkOption {
      description = "Git repository status";
      default = { };
      type = submodule (
        { config, ... }:
        {
          options = {
            # POWERLEVEL9K_VCS_BACKGROUND
            background = mkOption {
              type = nullOr color;
              example = "yellow";
              description = "The background color of this segment, as an xterm color id or name";
            };

            # POWERLEVEL9K_VCS_FOREGROUND
            foreground = mkOption {
              type = nullOr color;
              example = "magenta";
              description = "The color of this segment's text, as an xterm color id or name";
            };

            # POWERLEVEL9K_VCS_LOADING_FOREGROUND
            loading-foreground = mkOption {
              type = nullOr color;
              default = "grey58";
              example = "red";
              description = "The color of this segment's text when VCS info is still loading, as an xterm color id or name";
            };

            # This one doesn't map directly to a single option; instead, it
            # can be either:
            #   - null,     in which case POWERLEVEL9K_VCS_DISABLE_GITSTATUS_FORMATTING=false
            #               and no other variables are set
            #   - a string, in which case:
            #                 - POWERLEVEL9K_VCS_DISABLE_GITSTATUS_FORMATTING=true
            #                 - POWERLEVEL9K_VCS_CONTENT_EXPANSION='${$((my_git_formatter(1)))+${my_git_format}}'
            #                 - POWERLEVEL9K_VCS_LOADING_CONTENT_EXPANSION='${$((my_git_formatter(0)))+${my_git_format}}'
            formatter = mkOption {
              type = nullOr str;
              default = null;
              description = ''
                The body of the function used to format the git status part of the
                prompt. Use `typeset -g my_git_format=result` at the end of your
                function to set the result. See the gitstatusd reference for available
                variables: https://github.com/romkatv/gitstatus/blob/master/gitstatus.plugin.zsh.
                A set of pre-defined formatters are available under the `programs.zsh-powerlevel10k.git-formatters`
                attr-set:
                ${lib.join "\n" (map (m: "- `${m}`") (builtins.attrNames (import ./builtin-git-formatters.nix)))}
              '';
              example = ''
                emulate -L zsh

                # just display 'git:(current-branch-name)
                typeset -g my_git_format='git:('"$VCS_STATUS_LOCAL_BRANCH"')'
              '';
            };

            expression = mkOption {
              type = str;
              defaultText = "{option}`vcs.formatter`";
              example = "repo: $P9K_CONTENT";
              description = ''
                The expression to use for the element, where $P9K_CONTENT contains
                the status text. See p10k's docs for allowed escape sequences.
              '';
            };

            loading-expression = mkOption {
              type = str;
              defaultText = "{option}`vcs.formatter`";
              example = "repo(loading): $P9K_CONTENT";
              description = ''
                The expression to use for the element when VCS info is still
                loading, where $P9K_CONTENT contains the status text. See p10k's
                docs for allowed escape sequences.
              '';
            };
          };

          config = mkIf (config.formatter != null) {
            expression = mkOptionDefault "\${$((my_git_formatter(1)))+\${my_git_format}}";
            loading-expression = mkOptionDefault "\${$((my_git_formatter(0)))+\${my_git_format}}";
          };
        }
      );
    };

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
