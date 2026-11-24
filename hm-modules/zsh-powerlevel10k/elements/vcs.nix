{ lib, p10k-utils, ... }:
let
  inherit (lib) mkIf mkOption mkOptionDefault mkOverride;
  inherit (lib.types) nullOr str;

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

            loading-expression = mkOption {
              defaultText = "{option}`vcs.formatter`";
              example = "repo(loading): $P9K_CONTENT";
            };
          };

          config = mkIf (config.formatter != null) {
            loading-foreground = mkOptionDefault "grey58";

            # 1499 is juuuust above the priority of `mkOptionDefault`,
            # so that we silently override the value set by `mkElementOption`
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
            ${opts.formatter}
          }
          functions -M my_git_formatter 2>/dev/null
        ''
      }
    '');
}
