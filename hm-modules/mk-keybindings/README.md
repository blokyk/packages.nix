# `mk-keybindings`

When writing modules for graphical applications, you sometimes need to write
something to support keybindings, which can quickly become inconsistent between
different modules, on top of leading to a bunch of duplication.

`mk-keybindings.nix` is a function that generates a generic and flexible
keybinding-handling module, which will place the option at the specified
attribute path (e.g. `programs.foo.keybindings`) and allow you to specify how
that keybinding is reflected in the config (e.g. under which config option).

For the end-user, the option is an attribute set mapping actions to a keybinding
(or multiple, as support by some GNOME apps), which is represented as a list
containing each individual key (with their GTK name, see the file for a list
of all supported values).

To use it, you can use `lib.importApply`:

```nix
{ lib, ... }: {
  imports = [
    (lib.importApply <zoeee/hm-modules/mk-keybindings> {
      optPath = [ "programs" "foo" "keybindings" ];
      prefixPath = [ "dconf" "settings" "org/foo/keybindings" ];
      # optional, see docs in file
      setter = action: keybind: { ${action} = keybind; };
      # specifies that this app doesn't support multiple keybindings for
      # a single action, and thus the "keybind" argument to setter will be
      # a single string instead of a list.
      # optional, see docs in file
      multiKeybindings = false;
    })
  ];

  # example use for end-users
  programs.foo.keybindings = {
    # this will result in `dconf.settings."org/foo/keybindings".some-action = "<Alt><Super>Left"`
    some-action = ["<Alt>" "<Super>" "Left"];
  };
}
```

(Sorry about the `prefixPath` thing, I know it's awkward but it's unfortunately
necessary to avoid infinite recursion :/)

See the documentation in the file for more extensive info.
