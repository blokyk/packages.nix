{ lib, ... }: {
  programs.z8h.keybindings = {
    # Move cursor one char backward.
    backward-char = lib.mkOptionDefault [ "Left" ];
    # Move cursor one char forward.
    forward-char  = lib.mkOptionDefault [ "Right" ];
    # Move cursor to the beginning of line.
    beginning-of-line = lib.mkOptionDefault [ "Home" ];
    # Move cursor to the end of line.
    end-of-line = lib.mkOptionDefault [ "End" ];
    # Move cursor to the beginning of buffer.
    z4h-beginning-of-line = lib.mkMerge [
      (lib.mkOptionDefault [ "<Ctrl>" "Home" ])
      (lib.mkOptionDefault [ "<Alt>"  "Home"])
    ];
    # Move cursor to the end of buffer.
    z4h-end-of-line = lib.mkMerge [
      (lib.mkOptionDefault [ "<Ctrl>" "End" ])
      (lib.mkOptionDefault [ "<Alt>"  "End"])
    ];

    # Move cursor one zsh word forward.
    z4h-forward-zword  = lib.mkOptionDefault [ "<Ctrl>" "<Shift>" "Right" ];
    # Move cursor one zsh word backward.
    z4h-backward-zword = lib.mkOptionDefault [ "<Ctrl>" "<Shift>" "Left" ];
    # Move cursor one word backward.
    z4h-forward-word  = lib.mkMerge [
      (lib.mkOptionDefault [ "<Alt>" "f" ])
      (lib.mkOptionDefault [ "<Alt>" "F" ])
      (lib.mkOptionDefault [ "<Alt>" "Right" ])
      (lib.mkOptionDefault [ "<Ctrl>" "Right" ])
    ];
    # Move cursor one word forward.
    z4h-backward-word = lib.mkMerge [
      (lib.mkOptionDefault [ "<Alt>" "b" ])
      (lib.mkOptionDefault [ "<Alt>" "B" ])
      (lib.mkOptionDefault [ "<Alt>" "Left" ])
      (lib.mkOptionDefault [ "<Ctrl>" "Left" ])
    ];

    # Delete the character under the cursor.
    delete-char = lib.mkMerge [
      (lib.mkOptionDefault [ "<Ctrl>" "d" ])
      (lib.mkOptionDefault [ "<Ctrl>" "D" ])
      (lib.mkOptionDefault [ "Delete" ])
    ];
    # Delete next word.
    z4h-kill-word = lib.mkMerge [
      (lib.mkOptionDefault [ "<Alt>" "D" ])
      (lib.mkOptionDefault [ "<Ctrl>" "Delete" ])
      (lib.mkOptionDefault [ "<Alt>"  "Delete" ])
    ];
    # Delete previous word.
    z4h-backward-kill-word = lib.mkMerge [
      (lib.mkOptionDefault [ "<Ctrl>" "W" ])
      (lib.mkOptionDefault [ "<Alt>"  "Backspace" ])
      (lib.mkOptionDefault [ "<Ctrl>" "<Alt>" "Backspace" ])
    ];
    # Delete next zsh word.
    z4h-kill-zword = lib.mkOptionDefault [ "<Ctrl>" "<Shift>" "Delete" ];
    # Delete line before cursor.
    backward-kill-line = lib.mkMerge [
      (lib.mkOptionDefault [ "<Alt>" "k" ])
      (lib.mkOptionDefault [ "<Alt>" "K" ])
    ];
    # Delete all lines.
    kill-buffer = lib.mkMerge [
      (lib.mkOptionDefault [ "<Alt>" "j" ])
      (lib.mkOptionDefault [ "<Alt>" "J" ])
    ];

    # Push buffer to ephemeral (local) history (won't be saved to HISTFILE) and delete all lines.
    # (It can then be found by navigating local history with )
    z4h-stash-buffer = lib.mkMerge [
      (lib.mkOptionDefault [ "<Alt>" "o" ])
      (lib.mkOptionDefault [ "<Alt>" "O" ])
    ];

    # Accept autosuggestion.
    z4h-autosuggest-accept = lib.mkMerge [
      (lib.mkOptionDefault [ "<Alt>" "m" ])
      (lib.mkOptionDefault [ "<Alt>" "M" ])
    ];

    # Undo and redo.
    undo = lib.mkOptionDefault [ "<Shift>" "Tab" ];
    redo = lib.mkOptionDefault [ "<Alt>" "/" ];

    # Expand alias/glob/parameter.
    z4h-expand = lib.mkOptionDefault [ "<Ctrl>" "Space" ];

    # Generic command completion.
    # fixme: right now, this doesn't work, preventing completions
    # z4h-fzf-complete = lib.mkOptionDefault [ "Tab" ];

    # Show help for the command at cursor.
    run-help = lib.mkMerge [
      (lib.mkOptionDefault [ "<Alt>" "h" ])
      (lib.mkOptionDefault [ "<Alt>" "H" ])
    ];

    # Do nothing (better than printing '~').
    z4h-do-nothing = lib.mkMerge [
      (lib.mkOptionDefault [ "PageUp" ])
      (lib.mkOptionDefault [ "PageDown" ])
    ];

    # todo: prompt-at-bottom
    # if (( _z4h_can_save_restore_screen )) &&
    #    zstyle -T :z4h: prompt-at-bottom; then
    #   bindkey '^L'      z4h-clear-screen-soft-bottom   # ctrl+l
    #   bindkey '^[^L'    z4h-clear-screen-hard-bottom   # ctrl+alt+l
    # else
    #   bindkey '^L'      z4h-clear-screen-soft-top      # ctrl+l
    #   bindkey '^[^L'    z4h-clear-screen-hard-top      # ctrl+alt+l
    # fi

    # fixme: fzf-related stuff is broken
    # Command history.
    z4h-fzf-history =  [ "<Ctrl>" "R" ];
    # Directory history.
    # z4h-fzf-dir-history = lib.mkMerge [
    #   (lib.mkOptionDefault [ "<Alt>" "r" ])
    #   (lib.mkOptionDefault [ "<Alt>" "R" ])
    # ]);

    # Move cursor one line up or fetch the previous command with a matching prefix.
    z4h-up-prefix-local = lib.mkOptionDefault [ "Up" ];
    # Move cursor one line down or fetch the next command with a matching prefix.
    z4h-down-prefix-local = lib.mkOptionDefault [ "Down" ];

    # todo: add z8h.zsh-history-substring-search
    #   if (( _z4h_use[zsh-history-substring-search] )); then
    #     # Move cursor one line up or fetch the previous command from LOCAL history.
    #     bindkey '^P'      z4h-up-substring-local         # ctrl+p
    #     bindkey '^[[A'    z4h-up-substring-local         # up
    #     # Move cursor one line down or fetch the next command from LOCAL history.
    #     bindkey   '^N'    z4h-down-substring-local       # ctrl+n
    #     bindkey   '^[[B'  z4h-down-substring-local       # down
    #   else
    #     # Move cursor one line up or fetch the previous command from LOCAL history.
    #     bindkey '^P'      z4h-up-prefix-local            # ctrl+p
    #     bindkey '^[[A'    z4h-up-prefix-local            # up
    #     # Move cursor one line down or fetch the next command from LOCAL history.
    #     bindkey '^N'      z4h-down-prefix-local          # ctrl+n
    #     bindkey '^[[B'    z4h-down-prefix-local          # down
    #   fi

    # Move cursor one line up or fetch the previous command (without caring about the prefix)
    up-line-or-history = lib.mkOptionDefault [ "<Ctrl>" "Up" ];
    # Move cursor one line down or fetch the next command (without caring about the prefix)
    down-line-or = lib.mkOptionDefault [ "<Ctrl>" "Down" ];

    # cd into the previous directory.
    z4h-cd-back = lib.mkOptionDefault [ "<Shift>" "Left" ];
    # cd into the next directory.
    z4h-cd-forward = lib.mkOptionDefault [ "<Shift>" "Right" ];
    # cd into the parent directory.
    z4h-cd-up = lib.mkOptionDefault [ "<Shift>" "Up" ];
    # cd into a subdirectory (interactive).
    z4h-cd-down = lib.mkOptionDefault [ "<Shift>" "Down" ];
  };
}
