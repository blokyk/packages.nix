{ lib, ... }:
let
  inherit (lib) mkIf mkOption mkOptionDefault;
  inherit (lib.types) either enum int nullOr str submodule;

  consts = import ../option-enums.nix;

  color = either int (enum consts.colors);
in
{
  options = {
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
  };
}
