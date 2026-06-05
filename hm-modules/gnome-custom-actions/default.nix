{ config, lib, ... }:
let
  cfg = config.programs.gnome-shell.custom-actions;

  # i'm the author, i get to decide how i use my modules! (distant screams of old dead french guys)
  bindingType = import ../mk-keybindings/keybind-type.nix {
    inherit lib;
    _check = true;
    multiKeybindings = false;
  };

  dconfBase = "org/gnome/settings-daemon/plugins/media-keys";
  getActionPath = action:
    "${dconfBase}/custom-keybindings/${lib.strings.sanitizeDerivationName action}";
in {
  options.programs.gnome-shell = {
    custom-actions = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule {
          options = {
            binding = lib.mkOption {
              type = bindingType;
              description = ''
                The keybinding that activate this action.
              '';
              example = [ "<Super>" "v" ];
            };

            command = lib.mkOption {
              type = lib.types.str;
              description = ''
                The command to execute for this action.
              '';
              example = "firefox --private-window";
            };
          };
        }
      );
    };
  };

  config = {
    dconf.settings =
      let
        actSpecs =
          let
            toCustomAct = action: spec: {
              name = getActionPath action;
              value = {
                command = spec.command;
                name = action;
                binding =
                  if spec.binding == null then
                    ""
                  else
                    lib.concatStrings spec.binding;
              };
            };
          in lib.mapAttrs' toCustomAct cfg;

        globalDecls = {
          ${dconfBase}.custom-keybindings =
            lib.mapAttrsToList (act: _: "/${getActionPath act}/") cfg;
        };
      in
        lib.mkMerge [
          globalDecls
          actSpecs
        ];
  };
}
