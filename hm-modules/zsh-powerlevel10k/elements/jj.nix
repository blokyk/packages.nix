# https://github.com/indirect/dotfiles/blob/9c5f3b8b7b0c4afdad7c51b677cff4b5718cb6ad/dot_p10k.zsh#L1166-L1327
{ config, lib, p10k-utils, pkgs, ... }:
let
  inherit (lib) attrNames mkOption types;
  inherit (p10k-utils) isSegmentEnabled mkElementOption;

  awk = lib.getExe pkgs.gawk;
  cut = lib.getExe' pkgs.coreutils "cut";
  zsh-async = pkgs.fetchFromGitHub {
    owner = "mafredri";
    repo = "zsh-async";
    rev = "ee1d11b68c38dec24c22b1c51a45e8a815a79756";
    hash = "sha256-mkTmgSnfoZlTaOPhw0Y0yG1BkZv+oTo/eEisZZTN5nM=";
  };

  toStringOr = default: val: if val == null then default else toString val;

  cfg = config.jj;

  atomType = (with lib.types; addCheck (attrsOf anything) (s: s ? content && lib.isString s.content)) // {
    description = "atom definition, i.e. an attribute set with (at least) a `content` string attribute";
    descriptionClass = "nonRestrictiveClause";
  };
in {
  options.jj = mkElementOption {
    description = "jujutsu repo status";
    module = {
      options = {
        enabledAtoms = mkOption {
          description = ''
            The ordered list of parts ("atoms") of this prompt segment to enable.
            Atoms can be repeated to insert them multiple times, although you must then be careful they don't pollute each other's environment.

            A table of builtin atoms is available below, although they can be customized using the options under `jj.atoms.*`

            builtin jj atoms:
            -----------------
            at       | bookmark name and distance from @              | main›1
            remote   | count changes ahead/behind remote              | 2⇡1⇣
            change   | the current jj change ID and commit            | kkor 4b56
            desc     | current change description                     | first line of description (or  )
            status   | counts of added, removed, modified             | +1 -4 ^2
            op       | the current jj operation ID                    | b44825e56a5a
            spacer   | a single space                                 | ' '

            (the 'spacer' atom is also aliased to ' ')

            See the documentation of `jj.atoms` to learn how to create your own atoms.
            By default, all atoms declared under `jj.atoms.*` are enabled.
          '';

          type = with lib.types; listOf (enum (attrNames config.jj.atoms));

          # enable all atoms by default, with spaces between all of them
          default = [ "at" " " "remote" " " "change" " " "desc" " " "status" " " "op"];
          example = [ "at" " " "remote" " " "desc" ];
        };

        snapshotOnDisplay = mkOption {
          type = types.bool;
          default = true;
          description = ''
            Whether showing this prompt should cause a jj snapshot.
          '';
        };

        workflow = mkOption {
          # todo: add a `merge` workflow for when you have a single HEAD with multiple/many parents,
          #       and then `absorb` (or manually `squash`) the changes into their respective commits
          #       cf:
          #         - https://v5.chriskrycho.com/journal/jujutsu-megamerges-and-jj-absorb/
          #         - https://ofcr.se/jujutsu-merge-workflow
          type = types.enum [ "squash" "edit" ];
          # 'edit' might not be the most popular or recommended workflow,
          # but it is the least confusing when starting out with this prompt
          # segment, because it's the most similar to git's formatter
          default = "edit";
          description = ''
            The typical jj workflow you use.
            This will tweak which revision's info is used and displayed.

            With the 'edit' workflow, the current head change ('@') is used:
            For example, if the 'change' atom is used, it'll display the change ID of @;
            same for desc, status, etc.

            With the 'squash' workflow, the *parent* of the head change ('@-') is used:
            In that same example, we would instead display the change ID, description, status, etc. of @-
          '';
        };

        atoms = mkOption {
          description = ''
            A set of atoms for this prompt segment.
            There are already some built-in atoms, but you can add your own custom ones.

            To add a new atom, set the value of `programs.zsh-powerlevel10k.theme.jj.atoms.<name>.content` directly in your config;
            it should be the zsh code that'll get executed when rendering the prompt (typically to add new elements by appending to the `$res` shell variable).

            If your atom needs some options, you are free to add options under `atoms.<name>`, although you'll need to explicitly declare `atoms.<name>.content` (with type `str` or `lines`) to avoid infinite recursion.
          '';
          example = lib.literalExpression ''
            {
              programs.zsh-powerlevel10k.theme.jj.atoms = {
                myAtom.content = "res+='hello!'";
              }
            }
          '';
          type = types.submodule {
            freeformType = with types; attrsOf atomType;

            options = {
              at = {
                maxLength = mkOption {
                  type = types.nullOr types.ints.positive;
                  default = null;
                  example = 15;
                  description = ''
                    The maximum number of characters of the bookmark name to display before it gets truncated.
                  '';
                };

                content = mkOption {
                  type = types.lines;
                };
              };

              change = {
                showCommitID = mkOption {
                  type = types.bool;
                  default = true;
                  description = ''
                    Whether the 'change' atom should also show the commit ID.
                  '';
                };

                content = mkOption {
                  type = types.lines;
                };
              };

              desc = {
                maxLength = mkOption {
                  type = types.nullOr types.ints.positive;
                  default = null;
                  example = 32;
                  description = ''
                    The maximum number of characters of the description allowed before it gets truncated.
                  '';
                };

                emptyIcon = mkOption {
                  type = types.str;
                  default = "✏️";
                  example = "📝";
                  description = ''
                    The icon to display when the description is empty.
                  '';
                };

                content = mkOption {
                  type = types.lines;
                };
              };
            };
          };
        };
      };
    };
  };

  config = {
    vcs.formatter = lib.mkIf (isSegmentEnabled "jj") (
      lib.mkOrder 250 ''
        # (put in an anon function so extended_glob isn't applied to everything else)
        jj_dirs="$(() { emulate -L zsh -o extended_glob; echo ./(../)#(.jj)(#qN/); })"
        if [[ -n "$jj_dirs" ]]; then
          typeset -g my_git_format=""
          return
        fi
      ''
    );

    jj.atoms = {
      " ".content = ''res+=" "'';
      spacer.content = ''res+=" "'';

      # bookmark name and distance from @
      at.content = ''
        local status_color=%F{green}
        (( VCS_STATUS_COMMITS_AHEAD )) && status_color=%F{cyan}
        (( VCS_STATUS_COMMITS_BEHIND )) && status_color=%F{magenta}
        (( VCS_STATUS_COMMITS_AHEAD && VCS_STATUS_COMMITS_BEHIND )) && status_color=%F{red}

        local where=''${(V)VCS_STATUS_LOCAL_BRANCH}
        where="''${where//\%/%%}" # escape %
        # If local branch name or tag is at most 32 characters long, show it in full.
        # Otherwise show the first 12 … the last 12.
        (( $#where > 32 )) && where[13,-13]="…"
        res+="''${status_color}%${toStringOr "" cfg.atoms.at.maxLength}>…>$where%>>"

        # ‹42 if before the local bookmark
        (( VCS_STATUS_COMMITS_BEFORE )) && res+="‹''${VCS_STATUS_COMMITS_BEFORE}"
        # ›42 if beyond the local bookmark
        (( VCS_STATUS_COMMITS_AFTER )) && res+="›''${VCS_STATUS_COMMITS_AFTER}"
      '';

      remote.content = ''
        # ⇣42 if behind the remote.
        (( VCS_STATUS_COMMITS_BEHIND )) && res+="%F{green}⇣''${VCS_STATUS_COMMITS_BEHIND}"
        (( VCS_STATUS_COMMITS_BEHIND_PLUS )) && res+="''${VCS_STATUS_COMMITS_BEHIND_PLUS}"
        # ⇡42 if ahead of the remote; no leading space if also behind the remote: ⇣42⇡42.
        (( VCS_STATUS_COMMITS_AHEAD && !VCS_STATUS_COMMITS_BEHIND )) && res+=" "
        (( VCS_STATUS_COMMITS_AHEAD  )) && res+="%F{green}⇡''${VCS_STATUS_COMMITS_AHEAD}"
        (( VCS_STATUS_COMMITS_AHEAD_PLUS )) && res+="''${VCS_STATUS_COMMITS_AHEAD_PLUS}"
      '';

      change.content = ''
        res+="%B%F{magenta}$VCS_STATUS_CHANGE[1]%b%F{244}$VCS_STATUS_CHANGE[2]"

        # '💥🚧👻🔒' if the repo is in an unusual state.
        [[ -n $VCS_STATUS_ACTION     ]] && res+=" %F{red}$VCS_STATUS_ACTION"

        ${lib.optionalString cfg.atoms.change.showCommitID ''
          res+=" %B%F{blue}$VCS_STATUS_COMMIT[1]%b%F{244}$VCS_STATUS_COMMIT[2]"
        ''}
      '';

      desc.content = ''
        if [[ -n $VCS_STATUS_COMMIT_SUMMARY ]]; then
          res+="%F{green}%${toStringOr "" cfg.atoms.desc.maxLength}>…>$VCS_STATUS_COMMIT_SUMMARY%>>"
        else
          res+="%F{green}${cfg.atoms.desc.emptyIcon}"
        fi
      '';

      status.content = ''
        (( VCS_STATUS_NUM_STAGED_NEW )) && res+="%F{green}+''${VCS_STATUS_NUM_STAGED_NEW}"
        (( VCS_STATUS_NUM_STAGED_DELETED )) && res+="%F{red}-''${VCS_STATUS_NUM_STAGED_DELETED}"
        (( VCS_STATUS_NUM_STAGED )) && res+="%F{yellow}^''${VCS_STATUS_NUM_STAGED}"
      '';

      op.content = ''
        [[ -n $VCS_STATUS_OP ]] && res+="%F{blue}''${VCS_STATUS_OP}"
      '';
    };

    themeContent = lib.mkIf (isSegmentEnabled "jj")
      ''
        function jj_status() {
          emulate -L zsh
          cd "$1"

          # write a small alias that ensures jj commands behave predictably and don't modify the oplog
          jj() {
            command jj --ignore-working-copy --at-op=@ --no-pager "$@" 2>/dev/null
          }

          ${lib.optionalString cfg.snapshotOnDisplay ''
            command jj --at-op=@ util snapshot 1>/dev/null 2>/dev/null
          ''}

          local \
            VCS_STATUS_COMMITS_AHEAD \
            VCS_STATUS_COMMITS_AHEAD_PLUS \
            VCS_STATUS_COMMITS_BEHIND \
            VCS_STATUS_COMMITS_BEHIND_PLUS \
            VCS_STATUS_COMMITS_AFTER \
            VCS_STATUS_COMMITS_BEFORE \
            VCS_STATUS_COMMITS_LOCAL_BRANCH \
            VCS_STATUS_CHANGE \
            VCS_STATUS_COMMIT \
            VCS_STATUS_ACTION \
            VCS_STATUS_COMMIT_SUMMARY \
            VCS_STATUS_NUM_STAGED_NEW \
            VCS_STATUS_NUM_STAGED_DELETED \
            VCS_STATUS_NUM_STAGED \
            VCS_STATUS_OP

          () {
            local HEAD='${
              {
                squash = "@-";
                edit = "@";
              }.${cfg.workflow}
            }'

            local branch=$(
              jj log --no-graph --limit 1 -r "
                coalesce(
                  heads(::@ & (bookmarks() | remote_bookmarks() | tags())),
                  heads(@:: & (bookmarks() | remote_bookmarks() | tags())),
                  trunk()
                )" \
                -T "separate(' ', bookmarks, tags)" \
              | ${cut} -d ' ' -f 1
            )

            if [[ -n $branch ]]; then
              [[ $branch =~ "\*$" ]] && branch=''${branch::-1}

              VCS_STATUS_COMMITS_AFTER=''${#$(
                jj log --no-graph -r "$branch..$HEAD & (~empty() | merges())" -T '"n "'
              )}
              VCS_STATUS_COMMITS_BEFORE=''${#$(
                jj log --no-graph -r "$HEAD..$branch & (~empty() | merges())" -T '"n "'
              )}
              local counts=($(
                jj bookmark list -r $branch -T '
                  if(remote,
                    separate(" ",
                      name ++ "@" ++ remote,
                      coalesce(tracking_ahead_count.exact(), tracking_ahead_count.lower()),
                      coalesce(tracking_behind_count.exact(), tracking_behind_count.lower()),
                      if(tracking_ahead_count.exact(), "0", "+"),
                      if(tracking_behind_count.exact(), "0", "+"),
                    ) ++ "\n"
                  )'
              ))

              VCS_STATUS_LOCAL_BRANCH=$branch
              VCS_STATUS_COMMITS_AHEAD=$counts[2]
              VCS_STATUS_COMMITS_BEHIND=$counts[3]
              VCS_STATUS_COMMITS_AHEAD_PLUS=$counts[4]
              VCS_STATUS_COMMITS_BEHIND_PLUS=$counts[5]
            fi

            IFS="#" local change=($(
              jj log --no-graph --limit 1 -r "$HEAD" -T '
                  separate("#",
                    change_id.shortest(4).prefix(),
                    change_id.shortest(4).rest(),
                    commit_id.shortest(4).prefix(),
                    commit_id.shortest(4).rest(),
                    concat(
                      if(conflict, "💥"),
                      if(divergent, "🚧"),
                      if(hidden, "👻"),
                      if(immutable, "🔒"),
                    ),
                  )'
            ))

            VCS_STATUS_CHANGE=($change[1] $change[2])
            VCS_STATUS_COMMIT=($change[3] $change[4])
            VCS_STATUS_ACTION="$change[5]"

            VCS_STATUS_COMMIT_SUMMARY=$(
              jj log --no-graph --limit 1 -r "$HEAD" -T "description.first_line()"
            )

            local status_diff=($(
              jj log --no-graph -r "$HEAD" -T "diff.summary()" \
              | ${awk} 'BEGIN {a=0;d=0;m=0} /^A / {a++} /^D / {d++} /^M / {m++} /^R / {m++} /^C / {a++} END {print(a,d,m)}'
            ))

            VCS_STATUS_NUM_STAGED_NEW=$status_diff[1]
            VCS_STATUS_NUM_STAGED_DELETED=$status_diff[2]
            VCS_STATUS_NUM_STAGED=$status_diff[3]

            VCS_STATUS_OP=$(
              jj op log --limit 1 --no-graph -T "id.short()"
            )
          }

          local res

          ${
            lib.concatMapStringsSep "\n\n" (
              atom: ''
                # atom: ${atom}

                () {
                  ${cfg.atoms.${atom}.content}
                  res+='%b%u%s%f%k'
                }
              ''
            ) cfg.enabledAtoms
          }

          # return results
          echo $res
        }

        function jj_status_callback() {
          emulate -L zsh
          typeset -g _p10k_jj_status_stale= _p10k_jj_status_updated=1

          if [[ $2 -ne 0 ]]; then
            typeset -g _p10k_jj_status=
          else
            typeset -g _p10k_jj_status="$3"
          fi

          p10k display -r
        }

        source "${zsh-async}/async.zsh"

        typeset -g _p10k_jj_last_op=
        async_start_worker        jj_status_worker -u
        async_unregister_callback jj_status_worker
        async_register_callback   jj_status_worker jj_status_callback

        function prompt_jj() {
          emulate -L zsh -o extended_glob
          (( $+commands[jj]         )) || return
          [[ -n ./(../)#(.jj)(#qN/) ]] || return
          typeset -g _p10k_jj_status_stale=1 _p10k_jj_status_updated=
          p10k segment -f grey -c '$_p10k_jj_status_stale' -e -t '$_p10k_jj_status'
          p10k segment -c '$_p10k_jj_status_updated' -e -t '$_p10k_jj_status'
          async_job jj_status_worker jj_status $PWD
        }
      ''
    ;
  };
}
