{ lib, ... }:
{
  # Use VCS_STATUS_* parameters to assemble Git status. See reference:
  # https://github.com/romkatv/gitstatus/blob/master/gitstatus.plugin.zsh.
  robbyrussell = lib.mkMerge [
    # bold purple 'git:(' prefix
    (lib.mkOrder 501 ''my_git_format+="''${1+%B%4F}git:(''${1+%1F}"'')

      # either the branch name, or the commit if detached
      (lib.mkOrder 1000 ''my_git_format+=''${''${VCS_STATUS_LOCAL_BRANCH:-''${VCS_STATUS_COMMIT[1,8]}}//\%/%%}'')

    # close the 'git:('
    (lib.mkOrder 1200 ''my_git_format+="''${1+%4F})"'')

    # if the index or worktree is dirty, add a yellow X to the end
    (lib.mkOrder 1400 ''
      if (( VCS_STATUS_NUM_CONFLICTED || VCS_STATUS_NUM_STAGED ||
      VCS_STATUS_NUM_UNSTAGED   || VCS_STATUS_NUM_UNTRACKED )); then
    '')

      (lib.mkOrder 1450 ''my_git_format+=" ''${1+%3F}✗"'')

    (lib.mkOrder 1499 ''fi'')
  ];
}
