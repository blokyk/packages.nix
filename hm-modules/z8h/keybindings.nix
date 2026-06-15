{ config, lib, ... }:
let
  cfg = config.programs.z8h;

  baseKeyMap = {
    "<Ctrl>"  = "^";
    "<Alt>"   = "^[";
    Tab       = "^I";
    Space     = " ";
    Enter     = "^M";
    Escape    = "^[";
    Up        = "^[[A";
    Down      = "^[[B";
    Right     = "^[[C";
    Left      = "^[[D";
    Home      = "^[[H";
    End       = "^[[F";
    Insert    = "^[[2~";
    Delete    = "^[[3~";
    PageUp    = "^[[5~";
    PageDown  = "^[[6~";
    Backspace = "^?";
  };

  combinationReverseMap = [
    { mapTo = [ "^_" ];      from = [ "/" "<Ctrl>" ]; } # inverted because '/' sorts before '<'
    { mapTo = [ "^_" ];      from = [ "<Ctrl>" "_" ]; }

    { mapTo = [ "^[[Z" ];    from = [ "<Shift>" "Tab" ]; }
    { mapTo = [ "^[[1;2A" ]; from = [ "<Shift>" "Up" ]; }
    { mapTo = [ "^[[1;2B" ]; from = [ "<Shift>" "Down" ]; }
    { mapTo = [ "^[[1;2C" ]; from = [ "<Shift>" "Right" ]; }
    { mapTo = [ "^[[1;2D" ]; from = [ "<Shift>" "Left" ]; }
    { mapTo = [ "^[[1;2H" ]; from = [ "<Shift>" "Home" ]; }
    { mapTo = [ "^[[1;2F" ]; from = [ "<Shift>" "End" ]; }
    { mapTo = [ "^[[2;2~" ]; from = [ "<Shift>" "Insert" ]; }
    { mapTo = [ "^[[3;2~" ]; from = [ "<Shift>" "Delete" ]; }
    { mapTo = [ "^[[5;2~" ]; from = [ "<Shift>" "PageUp" ]; }
    { mapTo = [ "^[[6;2~" ]; from = [ "<Shift>" "PageDown" ]; }
    { mapTo = [ "^?" ];      from = [ "<Shift>" "Backspace" ]; }

    { mapTo = [ "^[[1;3A" ]; from = [ "<Alt>" "Up" ]; }
    { mapTo = [ "^[[1;3B" ]; from = [ "<Alt>" "Down" ]; }
    { mapTo = [ "^[[1;3C" ]; from = [ "<Alt>" "Right" ]; }
    { mapTo = [ "^[[1;3D" ]; from = [ "<Alt>" "Left" ]; }
    { mapTo = [ "^[[1;3H" ]; from = [ "<Alt>" "Home" ]; }
    { mapTo = [ "^[[1;3F" ]; from = [ "<Alt>" "End" ]; }
    { mapTo = [ "^[[2;3~" ]; from = [ "<Alt>" "Insert" ]; }
    { mapTo = [ "^[[3;3~" ]; from = [ "<Alt>" "Delete" ]; }
    { mapTo = [ "^[[5;3~" ]; from = [ "<Alt>" "PageUp" ]; }
    { mapTo = [ "^[[6;3~" ]; from = [ "<Alt>" "PageDown" ]; }

    { mapTo = [ "^[[1;4A" ]; from = [ "<Alt>" "<Shift>" "Up" ]; }
    { mapTo = [ "^[[1;4B" ]; from = [ "<Alt>" "<Shift>" "Down" ]; }
    { mapTo = [ "^[[1;4C" ]; from = [ "<Alt>" "<Shift>" "Right" ]; }
    { mapTo = [ "^[[1;4D" ]; from = [ "<Alt>" "<Shift>" "Left" ]; }
    { mapTo = [ "^[[1;4H" ]; from = [ "<Alt>" "<Shift>" "Home" ]; }
    { mapTo = [ "^[[1;4F" ]; from = [ "<Alt>" "<Shift>" "End" ]; }
    { mapTo = [ "^[[2;4~" ]; from = [ "<Alt>" "<Shift>" "Insert" ]; }
    { mapTo = [ "^[[3;4~" ]; from = [ "<Alt>" "<Shift>" "Delete" ]; }
    { mapTo = [ "^[[5;4~" ]; from = [ "<Alt>" "<Shift>" "PageUp" ]; }
    { mapTo = [ "^[[6;4~" ]; from = [ "<Alt>" "<Shift>" "PageDown" ]; }
    { mapTo = [ "^[^H" ];    from = [ "<Alt>" "<Shift>" "Backspace" ]; }

    { mapTo = [ "^[[1;5A" ]; from = [ "<Ctrl>" "Up" ]; }
    { mapTo = [ "^[[1;5B" ]; from = [ "<Ctrl>" "Down" ]; }
    { mapTo = [ "^[[1;5C" ]; from = [ "<Ctrl>" "Right" ]; }
    { mapTo = [ "^[[1;5D" ]; from = [ "<Ctrl>" "Left" ]; }
    { mapTo = [ "^[[1;5H" ]; from = [ "<Ctrl>" "Home" ]; }
    { mapTo = [ "^[[1;5F" ]; from = [ "<Ctrl>" "End" ]; }
    { mapTo = [ "^[[2;5~" ]; from = [ "<Ctrl>" "Insert" ]; }
    { mapTo = [ "^[[3;5~" ]; from = [ "<Ctrl>" "Delete" ]; }
    { mapTo = [ "^[[5;5~" ]; from = [ "<Ctrl>" "PageUp" ]; }
    { mapTo = [ "^[[6;5~" ]; from = [ "<Ctrl>" "PageDown" ]; }
    { mapTo = [ "^H"      ]; from = [ "<Ctrl>" "Backspace" ]; }

    { mapTo = [ "^[[1;6A" ]; from = [ "<Ctrl>" "<Shift>" "Up" ]; }
    { mapTo = [ "^[[1;6B" ]; from = [ "<Ctrl>" "<Shift>" "Down" ]; }
    { mapTo = [ "^[[1;6C" ]; from = [ "<Ctrl>" "<Shift>" "Right" ]; }
    { mapTo = [ "^[[1;6D" ]; from = [ "<Ctrl>" "<Shift>" "Left" ]; }
    { mapTo = [ "^[[1;6H" ]; from = [ "<Ctrl>" "<Shift>" "Home" ]; }
    { mapTo = [ "^[[1;6F" ]; from = [ "<Ctrl>" "<Shift>" "End" ]; }
    { mapTo = [ "^[[2;6~" ]; from = [ "<Ctrl>" "<Shift>" "Insert" ]; }
    { mapTo = [ "^[[3;6~" ]; from = [ "<Ctrl>" "<Shift>" "Delete" ]; }
    { mapTo = [ "^[[5;6~" ]; from = [ "<Ctrl>" "<Shift>" "PageUp" ]; }
    { mapTo = [ "^[[6;6~" ]; from = [ "<Ctrl>" "<Shift>" "PageDown" ]; }
    { mapTo = [ "^?" ];      from = [ "<Ctrl>" "<Shift>" "Backspace" ]; }

    { mapTo = [ "^[[1;7A" ]; from = [ "<Ctrl>" "<Alt>" "Up" ]; }
    { mapTo = [ "^[[1;7B" ]; from = [ "<Ctrl>" "<Alt>" "Down" ]; }
    { mapTo = [ "^[[1;7C" ]; from = [ "<Ctrl>" "<Alt>" "Right" ]; }
    { mapTo = [ "^[[1;7D" ]; from = [ "<Ctrl>" "<Alt>" "Left" ]; }
    { mapTo = [ "^[[1;7H" ]; from = [ "<Ctrl>" "<Alt>" "Home" ]; }
    { mapTo = [ "^[[1;7F" ]; from = [ "<Ctrl>" "<Alt>" "End" ]; }
    { mapTo = [ "^[[2;7~" ]; from = [ "<Ctrl>" "<Alt>" "Insert" ]; }
    { mapTo = [ "^[[3;7~" ]; from = [ "<Ctrl>" "<Alt>" "Delete" ]; }
    { mapTo = [ "^[[5;7~" ]; from = [ "<Ctrl>" "<Alt>" "PageUp" ]; }
    { mapTo = [ "^[[6;7~" ]; from = [ "<Ctrl>" "<Alt>" "PageDown" ]; }
    { mapTo = [ "^[^H" ];    from = [ "<Ctrl>" "<Alt>" "Backspace" ]; }

    { mapTo = [ "^[[1;8A" ]; from = [ "<Alt>" "<Ctrl>" "<Shift>" "Up" ]; }
    { mapTo = [ "^[[1;8B" ]; from = [ "<Alt>" "<Ctrl>" "<Shift>" "Down" ]; }
    { mapTo = [ "^[[1;8C" ]; from = [ "<Alt>" "<Ctrl>" "<Shift>" "Right" ]; }
    { mapTo = [ "^[[1;8D" ]; from = [ "<Alt>" "<Ctrl>" "<Shift>" "Left" ]; }
    { mapTo = [ "^[[1;8H" ]; from = [ "<Alt>" "<Ctrl>" "<Shift>" "Home" ]; }
    { mapTo = [ "^[[1;8F" ]; from = [ "<Alt>" "<Ctrl>" "<Shift>" "End" ]; }
    { mapTo = [ "^[[2;8~" ]; from = [ "<Alt>" "<Ctrl>" "<Shift>" "Insert" ]; }
    { mapTo = [ "^[[3;8~" ]; from = [ "<Alt>" "<Ctrl>" "<Shift>" "Delete" ]; }
    { mapTo = [ "^[[5;8~" ]; from = [ "<Alt>" "<Ctrl>" "<Shift>" "PageUp" ]; }
    { mapTo = [ "^[[6;8~" ]; from = [ "<Alt>" "<Ctrl>" "<Shift>" "PageDown" ]; }
    { mapTo = [ "^?" ];      from = [ "<Alt>" "<Ctrl>" "<Shift>" "Backspace" ]; }
  ];

  normalizeKey = key: {
    "<Primary>" = "<Ctrl>";
    "<Control>" = "<Ctrl>";
    "<Ctl>"     = "<Ctrl>";
    "<Shft>"    = "<Shift>";
    "space"     = "Space";
  }.${key} or key;

  sortKeys =
    let
      f = a: b: lib.elemAt (lib.attrNames { ${a} = null; ${b} = null; }) 0 == a;
    in
      lib.sort f;

  mapKeyCombinations = _keys:
    let
      keys = sortKeys _keys;
    in
      (lib.findFirst
        (mapping: mapping.from == keys)
        { mapTo = keys; } # by default, just return the original keys
        combinationReverseMap).mapTo;
in {
  imports = [
    ./fn

    (lib.modules.importApply ../mk-keybindings {
      multiKeybindings = true;
      optPath = [ "programs" "z8h" "keybindings" ];
      prefixPath = [ "programs" "zsh" "initBlocks" "keybindings" ];
      setter = action: keybinds: lib.mkIf cfg.enable (
        lib.hm.dag.entryAfter [ "z4h-prelude" "register-zle-widgets" ] (
          lib.concatMapStringsSep "\n" (keybind: "bindkey '${keybind}' ${action}") keybinds
        )
      );
      keyMapper = key: baseKeyMap.${key} or key;
    })
  ];

  options = {
    programs.z8h.keybindings = lib.mkOption {
      # remap whole key combinations instead of individual keys
      apply = lib.mapAttrs (_: keys: map (keybind: mapKeyCombinations (map normalizeKey keybind)) keys);
    };
  };

  config = {
    # assertions = lib.mapAttrsToList (action: binding: {
    #   assertion = config.programs.zsh.siteFunctions ? ${action};
    #   message = "programs.z8h.keybindings: action '${action}' is not a known function from programs.zsh.siteFunctions";
    # }) cfg.keybindings;

    # reset the keymap completely
    programs.zsh.initBlocks = lib.mkIf cfg.enable {
      reset-bindkey = lib.hm.dag.entryBetween [ "keybindings" ] [ "z4h-prelude" ] ''
        bindkey -d
        bindkey -e
      '';
    };
  };
}
