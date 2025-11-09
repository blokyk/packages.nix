{
    robbyrussell = ''
        emulate -L zsh
        if [[ -n $P9K_CONTENT ]]; then
            # If P9K_CONTENT is not empty, it's either "loading" or from vcs_info (not from
            # gitstatus plugin). VCS_STATUS_* parameters are not available in this case.
            typeset -g my_git_format=$P9K_CONTENT
        else
            # Use VCS_STATUS_* parameters to assemble Git status. See reference:
            # https://github.com/romkatv/gitstatus/blob/master/gitstatus.plugin.zsh.
            typeset -g my_git_format="''${1+%B%4F}git:(''${1+%1F}"
            my_git_format+=''${''${VCS_STATUS_LOCAL_BRANCH:-''${VCS_STATUS_COMMIT[1,8]}}//\%/%%}
            my_git_format+="''${1+%4F})"
            if (( VCS_STATUS_NUM_CONFLICTED || VCS_STATUS_NUM_STAGED ||
                  VCS_STATUS_NUM_UNSTAGED   || VCS_STATUS_NUM_UNTRACKED )); then
                my_git_format+=" ''${1+%3F}✗"
            fi
        fi
    '';
}