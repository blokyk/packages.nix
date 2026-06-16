{ config, lib, ... }:
let
  cfg = config.programs.z8h;
  mkIfElse = cond: yes: no: lib.mkMerge [(lib.mkIf cond yes) (lib.mkIf (!cond) no)];
in {
  programs.z8h.blocks = {
    add-shell-integration-function = lib.hm.dag.entryAfter [ "load-functions" ] (
      mkIfElse (cfg.terminal.shell-integration != null)
        # then
        ''
          if [[ $TERM != (dumb|linux) &&
                $ITERM_SHELL_INTEGRATION_INSTALLED != Yes &&
                -z $NVIM_LISTEN_ADDRESS
                && -z $NVIM ]]; then
            -z4h-enable-iterm2-integration
          fi
        ''
        # else
        ''
          function -z4h-iterm2-precmd() { }
          function -z4h-iterm2-preexec() { }
        ''
    );
  };
}
