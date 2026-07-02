{
  robbyrussell = {
    left-prompt = [
      "prompt-char"
      "dir"
      "vcs"
    ];
    right-prompt = [ ];

    background = null;
    whitespace = "";
    subsegment-separator = " ";
    segment-separator = "";
    icons-expression = "";

    prompt-char = {
      ok.foreground = "green";
      error.foreground = "red";
      symbol = "%B➜%b ";
    };

    dir = {
      foreground = "cyan";
      shorten.strategy = "truncate_to_last";
      expression = "%B$P9K_CONTENT%b";
    };

    vcs.formatter = (import ./builtin-git-formatters.nix).robbyrussell;
  };
}
