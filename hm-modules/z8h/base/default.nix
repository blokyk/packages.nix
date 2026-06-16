{ ... }: {
  imports = [
    ./autosuggestions.nix
    ./completions.nix
    ./keybindings.nix
  ];

  programs.zsh.localVariables = {
    # mark the missing \n at the end of a command output with a red block
    PROMPT_EOL_MARK = "%K{red} %k";

    # only alphanums make up words in word-based zle widgets
    WORDCHARS= "''";

    # don't eat space when typing '|' after a tab completion
    ZLE_REMOVE_SUFFIX_CHARS = "''";

    # wait for 200ms for the continuation of a key sequence
    KEYTIMEOUT = 20;

    # disable highlighting of text pasted into the command line
    zle_highlight = ["paste:none"];
  };
}
