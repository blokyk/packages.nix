# fixme: replace zstyle checks with config options

{ config, lib, ... }:
let
  cfg = config.programs.zsh.autosuggestion;
in {
  options = {
    programs.zsh.autosuggestion = {
      manual-rebind = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = ''
          disable automatic widget re-binding on each `precmd`.
          This can be a big boost to performance, but you'll need to handle re-binding yourself if any of the widget lists change or if you or another plugin wrap any of the autosuggest widgets.
          To re-bind widgets, run `_zsh_autosuggest_bind_widgets`.
        '';
      };

      history-ignore = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        description = ''
          Prevent offering suggestions for history entries that match the pattern.
        '';
        example = lib.literalExpression ''
          "cd *" # never suggest cd commands from history
        '';
      };

      completion-ignore = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        description = ''
          Prevent offering completion suggestions when the buffer matches that pattern.
        '';
        example = lib.literalExpression ''
          "git *" # never suggest git completions
        '';
      };

      widgets = {
        accept = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          description = ''
            Widgets in this array will accept the suggestion when invoked.
          '';
          default = [
            "forward-char"
            "end-of-line"
            "vi-forward-char"
            "vi-end-of-line"
            "vi-add-eol"
          ];
        };

        clear = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          description = ''
             Widgets in this array will clear the suggestion when invoked.
          '';
          default = [
            "history-search-forward"
            "history-search-backward"
            "history-beginning-search-forward"
            "history-beginning-search-backward"
            "history-beginning-search-forward-end"
            "history-beginning-search-backward-end"
            "history-substring-search-up"
            "history-substring-search-down"
            "up-line-or-beginning-search"
            "down-line-or-beginning-search"
            "up-line-or-history"
            "down-line-or-history"
            "accept-line"
            "copy-earlier-word"
          ];
        };

        execute = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          description = ''
            Widgets in this array will execute the suggestion when invoked.
          '';
          default = [];
        };

        ignore = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          description = ''
            Widgets in this array will not trigger any custom behavior.
          '';
          default = [
            "orig-*"
            "beep"
            "run-help"
            "set-local-history"
            "which-command"
            "yank"
            "yank-pop"
            "zle-*"
          ];
        };

        partial-accept = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          description = ''
            Widgets in this array will partially accept the suggestion when invoked.
          '';
          default = [
            "forward-word"
            "emacs-forward-word"
            "vi-forward-word"
            "vi-forward-word-end"
            "vi-forward-blank-word"
            "vi-forward-blank-word-end"
            "vi-find-next-char"
            "vi-find-next-char-skip"
          ];
        };
      };
    };
  };

  config = {
    programs.zsh.localVariables = {
      ZSH_AUTOSUGGEST_ACCEPT_WIDGETS = cfg.widgets.accept;
      ZSH_AUTOSUGGEST_CLEAR_WIDGETS = cfg.widgets.clear;
      ZSH_AUTOSUGGEST_EXECUTE_WIDGETS = cfg.widgets.execute;
      ZSH_AUTOSUGGEST_IGNORE_WIDGETS = cfg.widgets.ignore;
      ZSH_AUTOSUGGEST_PARTIAL_ACCEPT_WIDGETS = cfg.widgets.partial-accept;
    };
  };
}
