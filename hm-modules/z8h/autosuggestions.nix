{ config, lib, options, pkgs, ... }:
let
  cfg = config.programs.z8h;
in {
  imports = [ ./autosuggestions-impl.nix ];

  programs.zsh.autosuggestion = lib.mkIf cfg.enable {
    enable = true;
    manual-rebind = true;
    widgets = lib.mkMerge [
      {
        accept = [
          "z4h-end-of-buffer"
        ];

        clear = options.programs.zsh.autosuggestion.widgets.clear.default ++ [
          "z4h-fzf-history"
          "z4h-down-prefix-global"
          "z4h-down-prefix-local"
          "z4h-up-prefix-global"
          "z4h-up-prefix-local"
          # todo: zsh-history-substring-search
          # if (( _z4h_use[zsh-history-substring-search] )); then
          #   ZSH_AUTOSUGGEST_CLEAR_WIDGETS+=(
          #     z4h-down-substring-global
          #     z4h-down-substring-local
          #     z4h-up-substring-global
          #     z4h-up-substring-local
          #   )
          # fi
        ];

        ignore = [
          # fixme: this breaks zsh-autosuggest because seemingly every widget is ignored
          # local suggest_special=(
          #   $ZSH_AUTOSUGGEST_EXECUTE_WIDGETS
          #   $ZSH_AUTOSUGGEST_CLEAR_WIDGETS
          #   $ZSH_AUTOSUGGEST_PARTIAL_ACCEPT_WIDGETS
          #   $ZSH_AUTOSUGGEST_ACCEPT_WIDGETS)
          # typeset -g ZSH_AUTOSUGGEST_IGNORE_WIDGETS=(''${''${(k)widgets}:|suggest_special})
        ];

        # cf comment on accept
        partial-accept = options.programs.zsh.autosuggestion.widgets.partial-accept.default ++ [
          "z4h-forward-word"
          "z4h-forward-zword"
        ];
      }
      {
        ${cfg.autosuggestions.forward-char} = [
          "forward-char" "vi-forward-char"
        ];
      }
      {
        ${cfg.autosuggestions.end-of-line} = [
          "end-of-line" "vi-add-eol" "vi-end-of-line"
        ];
      }
    ];
  };

  programs.z8h.blocks = {
    # this is necessary because the z4h functions get autoloaded *after*
    # zsh-autosuggestion is sourced, which breaks its widget detection somehow
    #
    # (also there's random z4h stuff i don't understand)
    reload-autosuggestion = ''
      precmd_functions=(''${precmd_functions:#_zsh_autosuggest_start})

      # fixme: programs.zsh.autosuggestion.package doesn't exist :(
      source ${pkgs.zsh-autosuggestions}/share/zsh-autosuggestions/zsh-autosuggestions.zsh

      # fixme: idk why this would try to disable async?
      # unset ZSH_AUTOSUGGEST_USE_ASYNC

      # rebind things
      _zsh_autosuggest_start
    '';
  };
}
