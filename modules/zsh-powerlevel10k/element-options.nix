{ lib, config, ... }:
let
  consts = import ./option-enums.nix;

  color = lib.types.either (lib.types.int) (lib.types.enum consts.colors);
in
with lib; {
  options = {
    prompt-char = mkOption {
      description = "multi-functional prompt symbol; changes depending on vi mode: ❯, ❮, V, ▶ for insert, command, visual and replace mode respectively; turns red on error";
      default = { };
      type = types.submodule {
        options = {
          enable = mkEnableOption "the `prompt_char` (prompt symbol) prompt element";

          # POWERLEVEL9K_PROMPT_CHAR_BACKGROUND
          background = mkOption {
            type = types.nullOr color;
            default = null;
            example = "slateblue";
            description = "The background color of this segment, as an xterm color id or name";
          };

          # POWERLEVEL9K_PROMPT_CHAR_CONTENT_EXPANSION
          symbol = mkOption {
            type = types.str;
            default = "$P9K_CONTENT";
            example = "%B➜%b ";
            description = ''
              The prompt symbol to use. Refer to p10k's to see how this
              string is expanded, as well as the allowed sequences.
            '';
          };

          ok = mkOption {
            # todo: support vi modes
            description = "The prompt's style after a successful command";
            default = { };
            type = types.submodule {
              options = {
                # POWERLEVEL9K_PROMPT_CHAR_OK_{VIINS,VICMD,VIVIS}_FOREGROUND=green
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
            type = types.submodule {
              options = {
                # POWERLEVEL9K_PROMPT_CHAR_ERROR_{VIINS,VICMD,VIVIS}_FOREGROUND=green
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
      type = types.submodule {
        options = {
          enable = mkEnableOption "the `dir` (current directory) prompt element";

          # POWERLEVEL9K_DIR_BACKGROUND
          background = mkOption {
            type = types.nullOr color;
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
            type = types.submodule {
              options = {
                # POWERLEVEL9K_SHORTEN_STRATEGY
                strategy = mkOption {
                  type = types.enum [
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
                  type = types.str;
                  default = "";
                  example = "-";
                  description = "Replace removed segment suffixes with this symbol";
                };

                # POWERLEVEL9K_SHORTEN_DIR_LENGTH
                length = mkOption {
                  type = types.nullOr types.int;
                  default = null;
                  example = 3;
                  description = "The minimum length each path segment can be shortened to";
                };
              };
            };
          };

          # POWERLEVEL9K_DIR_PATH_ABSOLUTE
          absolute = mkOption {
            type = types.bool;
            default = false;
            example = true;
            description = "Whether the full absolute path should be displayed";
          };

          # POWERLEVEL9K_DIR_SHOW_WRITABLE
          writable = mkOption {
            type = types.bool;
            default = false;
            example = true;
            description = "Display an indicator of whether or not the current directory is writable";
          };

          # POWERLEVEL9K_DIR_CONTENT_EXPANSION
          expression = mkOption {
            type = types.str;
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
      type = types.submodule ({ config, ... }: {
        options = {
          enable = mkEnableOption "the `vcs` (git status) prompt element";

          # POWERLEVEL9K_VCS_BACKGROUND
          background = mkOption {
            type = types.nullOr color;
            default = null;
            example = "yellow";
            description = "The background color of this segment, as an xterm color id or name";
          };

          # POWERLEVEL9K_VCS_FOREGROUND
          foreground = mkOption {
            type = types.nullOr color;
            default = null;
            example = "magenta";
            description = "The color of this segment's text, as an xterm color id or name";
          };

          # POWERLEVEL9K_VCS_LOADING_FOREGROUND
          loading-foreground = mkOption {
            type = types.nullOr color;
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
            type = types.nullOr types.lines;
            default = null;
            description = ''
              The body of the function used to format the git status part of the
              prompt. Use `typeset -g my_git_format=result` at the end of your
              function to set the result. See the gitstatusd reference for available
              variables: https://github.com/romkatv/gitstatus/blob/master/gitstatus.plugin.zsh.
              A set of pre-defined formatters are available under the `programs.zsh-powerlevel10k.git-formatters`
              attr-set:
              ${mkMDList (builtins.attrNames (import ./builtin-git-formatters.nix))}
            '';
            example = ''
              emulate -L zsh

              # just display 'git(current-branch-name)
              typeset -g my_git_format='git:('"$VCS_STATUS_LOCAL_BRANCH"')'
            '';
          };

          expression = mkOption {
            type = types.str;
            default = "$P9K_CONTENT";
            example = "repo: $P9K_CONTENT";
            description = ''
              The expression to use for the element, where $P9K_CONTENT contains
              the status text. See p10k's docs for allowed escape sequences.
            '';
          };

          loading-expression = mkOption {
            type = types.str;
            default = "$P9K_CONTENT";
            example = "repo(loading): $P9K_CONTENT";
            description = ''
              The expression to use for the element when VCS info is still
              loading, where $P9K_CONTENT contains the status text. See p10k's
              docs for allowed escape sequences.
            '';
          };
        };

        config = mkIf (config.formatter != null) {
          expression = mkDefault "$\{$((my_git_formatter(1)))+$\{my_git_format}}";
          loading-expression = mkDefault "$\{$((my_git_formatter(0)))+$\{my_git_format}}";
        };
      });
    };
  };
}