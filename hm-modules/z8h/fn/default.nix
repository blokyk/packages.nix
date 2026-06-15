{ config, lib, pkgs, ... }:
let
  cfg = config.programs.z8h;
  fn-list = import ./list.nix { inherit config pkgs; };
in {
  programs.zsh = lib.mkIf cfg.enable {
    siteFunctions = fn-list;

    initBlocks = {
      register-zle-widgets = lib.hm.dag.entryAfter [ "z4h-prelude" ] ''
        functions -M -- _z4h_cursor_max 0 0

        zle -N up-line-or-beginning-search
        zle -N down-line-or-beginning-search
        zle -N z4h-accept-line
        zle -N z4h-eof
        zle -N z4h-exit
        zle -N z4h-expand
        zle -N z4h-forward-word
        zle -N z4h-kill-word
        zle -N z4h-backward-word
        zle -N z4h-backward-kill-word
        zle -N z4h-forward-zword
        zle -N z4h-kill-zword
        zle -N z4h-backward-zword
        zle -N z4h-backward-kill-zword
        zle -N z4h-quote-prev-zword
        zle -N z4h-beginning-of-buffer
        zle -N z4h-end-of-buffer
        zle -N z4h-stash-buffer
        zle -N z4h-fzf-complete
        zle -N z4h-up-prefix-local
        zle -N z4h-down-prefix-local
        zle -N z4h-up-prefix-global
        zle -N z4h-down-prefix-global
        if (( _z4h_use[zsh-history-substring-search] )); then
          zle -N z4h-up-substring-local
          zle -N z4h-down-substring-local
          zle -N z4h-up-substring-global
          zle -N z4h-down-substring-global
        fi
        zle -N z4h-cd-back
        zle -N z4h-cd-forward
        zle -N z4h-cd-up
        zle -N z4h-cd-down
        zle -N z4h-fzf-history
        zle -N z4h-fzf-dir-history
        zle -N z4h-autosuggest-accept
        zle -N z4h-do-nothing
        zle -N z4h-clear-screen-soft-top
        zle -N z4h-clear-screen-soft-bottom
        zle -N z4h-clear-screen-hard-top
        zle -N z4h-clear-screen-hard-bottom

        zle -C -- -z4h-comp-insert-all complete-word -z4h-comp-insert-all
      '';
    };
  };
}
