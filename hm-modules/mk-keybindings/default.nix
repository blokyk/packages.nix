/**
  Create a module that manages the keybindings of an app or services through dconf.

  The returned module creates an option at the given attr path and handles setting
  the keybindings at the requested dconf path (as well as checking that the keys
  used in each keybinding is valid).
  That option is an attribute set mapping action names to non-empty lists containing
  strings representing the individual keys in the keybinding. If an attribute is
  null, that keybinding is explicitly unset; on the other hand, not specifying
  an attribute will just not touch anything, thus leaving the dconf setting to
  what it is by default (the app's default, a previous setting, etc.).

  # Inputs

  `optPath` :: [String]

  : The attribute path at which to add this option.

    For example, `optPath = [ "programs" "gnome-shell" "keybindings" ]`
    will set `programs.gnome-shell.keybindings` to an option that
    behaves as specified above.


  `prefixPath` :: [String]

  : An unfortunately necessary parameter to avoid infinite recursion.
    This should an attribute path that is a common prefix to all the values
    that will be set.

    For example, with `prefixPath = [ "dconf" "settings" ]`,
    all the values returned by `setter` will be set under the `dconf.settings`
    config option.


  `setter` :: String -> (KeybindStr | [KeybindStr]) -> Config (aka AttrSet)

  : A function to map each keybinding (or list of keybinding, if
    `multiKeybindings = true`) to a value under `prefixPath`. The second
    argument will be a single string representing the keybinding if
    `multiKeybindings = false`, and it'll be a list of keybinding strings
    if `multiKeybindings = true`.

    Note that this doesn't have to return an attribute set at all, if `prefixPath`
    doesn't point to an attrset option; it could be a list, a multi-line string,
    whatever you need.

    The result of each call to `setter` will be merged with `lib.mkMerge`.

    For example, given the `prefixPath` in the previous example, this could
    be `action: keybind: { "org/foo/keybindings/${action}".key = keybind; }`,
    which, for `some-action = ["<Control>" "c"]`, would result in setting
    `dconf.settings."org/foo/keybindings/some-action".key = "<Control>c"`.

    Optional, default is `action: keybinds: { ${action} = keybinds; }`


  `multiKeybindings` :: Bool

  : Whether the application being configured supports actions being bound to
    multiple different keybindings.

    For example, gnome-shell does (and stores keybindings as lists);
    while tilix doesn't (and stores keybindings as strings).

    Optional, `true` by default.


  `keyMapper` :: String -> String

  : A function that translates a key from a GTK name (e.g. `<Primary>`) to
    an application-specific name. (See the code for full list of available keys.)

    Useful if the application you're generating keybindings for has different
    names for keys.

    Optional, noop (`lib.id`) by default, which means the keys will have their GTK names.
*/
{
  optPath,
  prefixPath,
  setter ? (action: keys: { ${action} = keys; }),
  multiKeybindings ? true,
  keyMapper ? _:_,
  _check ? true
}:
{ config, lib, ... }:
let
  inherit (lib) getAttrFromPath mapAttrs mapAttrsToList mkOption setAttrByPath types;

  keybindingsType = import ./keybind-type.nix { inherit lib multiKeybindings _check; };

  opt = mkOption {
      type = with types; attrsOf (nullOr keybindingsType);
      default = { };
      example = {
        screenshot = [ "<Shift>" "Print" ];
        switch-layout = [ ["<Shift>" "Space"] ["<Super>" "Space"] ];
        toggle-message-tray = null;
      };
    };

in {
  options = setAttrByPath optPath opt;

  config = setAttrByPath prefixPath (lib.mkMerge (
    mapAttrsToList setter (
      let
        cfg = getAttrFromPath optPath config;
        keysToStr = keys:
          if keys == null then
            ""
          else
            lib.concatStrings (map keyMapper keys);
        multiToKeysStr = bindings:
          if bindings == null then
            []
          else
            # the lists of keys inside bindings can't ever be null,
            # so we don't have to worry about that
            map keysToStr bindings;
      in
        if multiKeybindings then
          mapAttrs
            (_: multiToKeysStr)
            cfg
        else
          mapAttrs
            (_: keysToStr)
            cfg
    )
  ));
}
