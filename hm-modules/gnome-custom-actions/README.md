# `gnome-custom-actions`

Adds a `programs.gnome-shell.custom-actions` option that allows setting
keybindings for custom actions:

```nix
{ ... }: {
    imports = [ <zoeee/hm-modules/gnome-custom-actions> ];

    programs.gnome-shell.custom-actions = {
        "Open Firefox" = {
            binding = [ "<Control>" "<Alt>" "g" ];
            command = "firefox";
        }
    };
}
```

The `binding` option can only have one value (you cannot assign multiple
keybindings to the same action), which must be a list of GTK key names. (The
error message will list them if you make a mistake, or you can see the full
list [in the code](../mk-keybindings/keybind-type.nix))

> [!NOTE]
> This requires the `media-keys` gnome-settings-daemon plugin (installed by
> default on Ubuntu, at time of writing (2026-06-05)).
