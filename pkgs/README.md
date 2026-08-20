# zoë's nix packages

A few things I packaged with nix.

There's a few ones I use everyday, which I "actively maintain," and are thus
unlikely to be broken (and if they are, please open an issue to notify me!),
although they might sometimes be out-of-date.
Some of these might already exist in nixpkgs, but the versions here are either
patched or packaged differently (e.g. suwayomi is built from source here,
whereas nixpkgs simply pulls a release tarball for it). Here are the ones I use
in my day-to-day configs:

- [`suwayomi/suwayomi-server`](https://github.com/Suwayomi/Suwayomi-Server), a
  self-hostable cross-platform port/clone of Tachiyomi/Mihon
- [`plp13/qman`](https://github.com/plp13/qman), a modern manual viewer for the
  terminal

I also package things for fun or for one-time use, but still publish them here
for convenience and posterity. They are more likely to be broken, though if you
rely on them, I'd be happy to fix them; you just gotta open an issue for it, and
I'll try to find the time. Here are the mostly-unmaintained ones:

- [`blokyk/nix-otel`](https://github.com/blokyk/nix-otel), an updated fork of
  [`lf-/nix-otel`](https://github.com/lf-/nix-otel)
- [`Jkeyuk/JDbrowser`](https://github.com/Jkeyuk/JDbrowser), a terminal SQLite
  database browser
- [`mcy/voltorb`](https://github.com/mcy/voltorb), a port of pokemon's Voltorb
  Flip to the terminal
- [`joedefen/grub-wiz`](https://github.com/joedefen/grub-wiz), a TUI for editing
  grub configurations
- [`aliev/baker`](https://github.com/aliev/baker), a scaffolding/templating CLI
- [`mbrukman/pdf-extract-svg`](https://github.com/mbrukman/pdf-extract-svg), a
  convenient GUI for extracting SVGs from PDF files.

See [the notes](#notes) on each package for more information.

## Usage

Import it just like any other package channel (e.g. `nixpkgs`), with
`import <zoeee/pkgs> {}`:

```nix
# in configuration.nix for example
{ ... }:
let
  zpkgs = import <zoeee/pkgs> {};
in {
  environment.systemPackages = [
      zpkgs.picoshare
      zpkgs.nix-otel
  ];
}
```

By default, if no `pkgs` argument is provided, it will use a pinned version of
nixpkgs. If needed, you can also pass specific `pkgs` objects. For example:

```nix
let
    mynix = (import <mynix> {}) // {
        buildGoModule =
            abort "no Golang in this wholesome christian minecraft server";
    };

    # will use `mynix.lib`
    zpkgs = import <zoeee/pkgs> { pkgs = mynix; };
in { ... }
```

## Notes

### `nix-otel`

This is a simple fork of `lf-`'s Nix OpenTelemetry plugin, updated to work with
modern (2.31) CppNix.
See [the note at the top of the fork's README for more info](https://github.com/blokyk/nix-otel#nix-otel).

### Suwayomi

#### Why?

`nixpkgs` already contains a `suwayomi-server` package, but it is unfortunately
simply a wrapper around the JAR files from the official stable releases. While
this doesn't change much for most cases, it means there is no easy way to patch
the software. Since I wanted to try out some pending/unmerged PRs, I wrote this
little from-source derivation.

#### Overriding

Because of [various](https://github.com/blokyk/packages.nix/commit/be49c74) [reasons](https://github.com/blokyk/packages.nix/commit/ad88f00),
the suwayomi derivation is a *little* more complicated than might seem
appropriate. This is unfortunate and I am working on a fix for it, but for the
time being it had to be split into a "wrapped" and "unwrapped" derivation to
strike an acceptable balance between correctness, maintainability, and
simplicity of overriding (since that was part of the point of writing that
derivation in the first place...).

Thus, overriding the various properties of the `suwayomi-server` derivation will
generally instead require overriding `suwayomi-server-unwrapped`, optionally
passing it to the `suwayomi-server` derivation if needed. Here is a toy
example:

```nix
let
  zpkgs = import <zoeee/pkgs> {};
  my-suwayomi-server = zpkgs.suwayomi-server.override {
    suwayomi-server-unwrapped = zpkgs.suwayomi-server-unwrapped.overrideAttrs {
      patches = [ ./my-custom.patch ];
    };
  };
in
  my-suwayomi-server
```

For a real-world example, check out [how I override suwayomi in my own config](https://github.com/blokyk/naqi.nix/blob/555d57b/services/suwayomi.nix).
