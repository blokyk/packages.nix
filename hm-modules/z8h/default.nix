{ config, lib, ... }:
let
  cfg = config.programs.z8h;
in {
  imports = [
    ../zsh-utils

    ./autosuggestions.nix
    ./fzf.nix
    ./keybindings.nix
    ./options.nix
    ./terminal.nix
    ./base
  ];

  config = {
    programs.zsh.hooks = lib.mkIf cfg.enable {
      preexec = "-z4h-set-term-title-preexec";
      precmd = "-z4h-set-term-title-precmd";
    };

    # push z4h stuff lower down in the zshrc
    programs.zsh.initBlocksPriority = lib.mkIf cfg.enable 2000;

    programs.zsh.initBlocks = lib.mkIf cfg.enable {
      z4h-prelude = ''
        mkdir -p ''${XDG_STATE_HOME:=$HOME/.local/state}/z4h/stickycache
        mkdir -p ''${XDG_CACHE_HOME:=$HOME/.cache}/z4h
      '';

      zle-prelude = lib.hm.dag.entryAfter [ "z4h-prelude" ] ''
        PROMPT_EOL_MARK='%K{red} %k'    # mark the missing \n at the end of a command output with a red block
        WORDCHARS='''                   # only alphanums make up words in word-based zle widgets
        ZLE_REMOVE_SUFFIX_CHARS='''     # don't eat space when typing '|' after a tab completion
        KEYTIMEOUT=20                   # wait for 200ms for the continuation of a key sequence
        zle_highlight=('paste:none')    # disable highlighting of text pasted into the command line

        autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
        autoload -Uz run-help ''${^fpath}/run-help-^*.zwc(N:t)
      '';

      z4h-init = lib.hm.dag.entryAfter [ "z4h-prelude" ] ''
        # todo: this is basically going to be a simplified version of main.zsh
        # without all the checks and installation stuff

        typeset -gr _z4h_opt='emulate -L zsh &&
          setopt typeset_silent pipe_fail extended_glob prompt_percent no_prompt_subst &&
          setopt no_prompt_bang no_bg_nice no_aliases'

        zmodload -s zsh/terminfo zsh/zselect                             || return
        zmodload zsh/{datetime,langinfo,parameter,system,terminfo,zutil} || return
        zmodload -F zsh/files b:{zf_mkdir,zf_mv,zf_rm,zf_rmdir,zf_ln}    || return
        zmodload -F zsh/stat b:zstat                                     || return

        # setting _z4h_tty_fd is important for a bunch of widgets
        if [[ -w $TTY ]]; then
          typeset -gi _z4h_tty_fd
          sysopen -o cloexec -rwu _z4h_tty_fd -- $TTY || return
          typeset -gri _z4h_tty_fd
        elif [[ -w /dev/tty ]]; then
          typeset -gi _z4h_tty_fd
          if sysopen -o cloexec -rwu _z4h_tty_fd -- /dev/tty 2>/dev/null; then
            typeset -gri _z4h_tty_fd
          else
            unset _z4h_tty_fd
          fi
        fi
      '';
    };
  };
}
