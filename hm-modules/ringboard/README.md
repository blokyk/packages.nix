# `ringboard`

A home-manager module for managing the [`ringboard`](https://github.com/SUPERCILEX/clipboard-history)
clipboard manager. This a very straightforward port of [the existing nixos module](https://github.com/NixOS/nixpkgs/blob/6c9a78c09ff4d6c21d0319114873508a6ec01655/nixos/modules/services/misc/ringboard.nix),
written and maintained by [@magnetophon](https://github.com/magnetophon).

Since the ringboard server is mostly only useful in cooperation with a listener,
it will only be enabled if either `services.ringboard.x11.enable` or
`services.ringboard.wayland.enable` is set. If you are using a system that
might run under either `x11` or `wayland`, you can enable both, and it will
select the right one at runtime based on `$XDG_SESSION_TYPE`.

Here is an example config:

```nix
{ ... }: {
  imports = [ <zoeee/hm-modules> ];

  services.ringboard = {
    x11.enable = true;
  }
}
```
