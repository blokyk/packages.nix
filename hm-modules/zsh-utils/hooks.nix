{ config, lib, ... }:
let
  inherit (lib) singleton;
  inherit (lib.types) attrsOf coercedTo listOf str;
  inherit (lib.options) mkOption;
  cfg = config.programs.zsh;
in {
  options = {
    # todo: check that the name of the hook is valid?
    # honestly, we could make each hook value have an optional
    # flag that says "this is a command, please generate a function for it k thx xoxo"
    programs.zsh.hooks = mkOption {
      type = attrsOf (
        coercedTo
          str
          singleton
          (listOf str)
      );
      default = {};
      description = ''
        A set of named functions (not commands!) to run when the given action (hook) is done.
        Valid hooks are:
          - chpwd
          - precmd
          - preexec
          - periodic
          - zshaddhistory
          - zshexit
          - zsh_directory_name
        See `zshmisc(1)`, section "SPECIAL FUNCTIONS", header "Hook Functions" for their behaviour.
        See `zshexpn(1)`, section "FILENAME EXPANSION", header "Dynamic named directories" for the behaviour of `zsh_directory_name`.
      '';
      example = {
        chpwd = "ls";
      };
    };
  };

  config = {
    programs.zsh.initContent =
      let
        hookLines = lib.mapAttrsToList
          (hook: lib.concatMapStringsSep "\n" (func: "add-zsh-hook ${hook} ${func}"))
          cfg.hooks;
      in
        lib.mkAfter ''
          autoload -Uz add-zsh-hook
          ${lib.concatLines hookLines}
        '';
  };
}
