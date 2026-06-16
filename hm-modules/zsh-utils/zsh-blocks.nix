{ config, lib, ... }:
let
  inherit (lib)
    concatMapStringsSep
    mkOption
    literalExpression
    types;

  inherit (lib.hm) dag;

  cfg = config.programs.zsh;
in {
  options = {
    programs.zsh.initBlocksPriority = mkOption {
      type = lib.types.int;
      default = lib.modules.defaultOrderPriority;
      description = ''
        The priority (argument of `lib.mkOrder`) that will be used for inserting the final concatenated result of all the blocks.
      '';
    };

    programs.zsh.initBlocks = mkOption {
      type = lib.hm.types.dagOf types.lines;
      description = ''
        A set of DAG blocks defining the sequence of commands to add to .zshrc
      '';
      default = { };

      example = literalExpression ''
        {
          install-plugins = lib.hm.dag.entryBefore ["z4h-init"] '''
            z4h install nix-community/nix-zsh-completions
          ''';

          set-opts = '''
            setopt glob_dots
            setopt no_auto_menu
            setopt no_nomatch
          ''';

          set-keybinds = lib.hm.dag.entryAfter ["z4h-init"] '''
            z4h bindkey z4h-kill-word Ctrl+Delete
          ''';
        };
      '';
    };
  };

  config = {
    programs.zsh.initContent =
      let
        sortedNodesRaw = dag.topoSort cfg.initBlocks;
        sortedNodes = sortedNodesRaw.result
            or (throw "Dependency cycle in zsh init config: ${builtins.toJSON sortedNodesRaw}");

        blockToString = block: ''
          # --- ${block.name} ---

          ${block.data}
        '';
      in
        lib.mkOrder cfg.initBlocksPriority (concatMapStringsSep "\n\n" blockToString sortedNodes);
  };
}
