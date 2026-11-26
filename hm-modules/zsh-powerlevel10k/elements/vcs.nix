{ lib, p10k-utils, ... }:
let
  inherit (lib) mkIf mkOption mkOptionDefault mkOverride;
  inherit (lib.types) lines nullOr;

  inherit (p10k-utils) genPromptOpts mkElementOption;
in
{
  options = {
    vcs = mkElementOption {
      description = "Git repository status";
      module = (
        { config, ... }:
        {
          options = {
            # This one doesn't map directly to a single option; instead, it
            # can be either:
            #   - null,     in which case POWERLEVEL9K_VCS_DISABLE_GITSTATUS_FORMATTING=false
            #               and no other variables are explicitly set
            #   - a string, in which case:
            #                 - POWERLEVEL9K_VCS_DISABLE_GITSTATUS_FORMATTING=true
            #                 - POWERLEVEL9K_VCS_CONTENT_EXPANSION='${$((my_git_formatter(1)))+${my_git_format}}'
            #                 - POWERLEVEL9K_VCS_LOADING_CONTENT_EXPANSION='${$((my_git_formatter(0)))+${my_git_format}}'
            formatter = mkOption {
              type = nullOr lines;
              default = null;
              description = ''
                The body of the function used to format the git status part of the prompt.
                See the gitstatusd reference for available variables: https://github.com/romkatv/gitstatus/blob/master/gitstatus.plugin.zsh.

                Use `my_git_format="your result here"` at the end of your function to set the result.

                A set of pre-defined formatters are available under the `programs.zsh-powerlevel10k.git-formatters` attrset:
                ${lib.join "\n" (map (m: "- `${m}`") (builtins.attrNames (import ./builtin-git-formatters.nix)))}
              '';
              example = ''
                # just display 'git:(current-branch-name)'
                typeset -g my_git_format='git:('"$VCS_STATUS_LOCAL_BRANCH"')'
              '';
            };

            loading-expression = mkOption {
              defaultText = "{option}`vcs.formatter`";
              example = "repo(loading): $P9K_CONTENT";
            };
          };

          config = mkIf (config.formatter != null) {
            loading-foreground = mkOptionDefault "grey58";

            # 1499 is juuuust above the priority of `mkOptionDefault`,
            # so that we silently override the value set by `mkElementOption`,
            # but are still overridden by mkDefault and others
            expression = mkOverride 1499 "\${$((my_git_formatter(1)))+\${my_git_format}}";
            loading-expression = mkOverride 1499 "\${$((my_git_formatter(0)))+\${my_git_format}}";
          };
        }
      );
    };
  };

  config.themeContent =
    genPromptOpts "vcs" (opts: {}) (opts: ''
      ${
        if (opts.formatter == null) then ''
          typeset -g POWERLEVEL9K_VCS_DISABLE_GITSTATUS_FORMATTING=false
        '' else ''
          typeset -g POWERLEVEL9K_VCS_DISABLE_GITSTATUS_FORMATTING=true
          function my_git_formatter() {
            emulate -L zsh

            typeset -g my_git_format=

            if [[ -n "$P9K_CONTENT" ]]; then
                # If P9K_CONTENT is not empty, it's either "loading" or from vcs_info (not from
                # gitstatus plugin). VCS_STATUS_* parameters are not available in this case.
                my_git_format="$P9K_CONTENT"
                return
            fi

            ${opts.formatter}
          }
          functions -M my_git_formatter 2>/dev/null
        ''
      }
    '');
}
