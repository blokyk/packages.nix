# zoë's nix packages

A few nix packages I wrote (how surprising!). Currently available:

- [`mtlynch/picoshare`](https://github.com/mtlynch/picoshare/), a minimal
  self-hostable file-sharing service
- [`blokyk/nix-otel`](https://github.com/blokyk/nix-otel), an updated fork of
  [`lf-/nix-otel`](https://github.com/lf-/nix-otel)
- [`TeXlyre/TeXlyre`](https://github.com/texlyre/texlyre), a self-hostable
  LaTeX and typst web editor
- [`suwayomi/suwayomi-server`](https://github.com/Suwayomi/Suwayomi-Server), a
  self-hostable cross-platform port/clone of Tachiyomi/Mihon.

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

By default, if no `pkgs` argument is provided, it will `import <nixpkgs>`. If
needed, you can also pass specific `pkgs` objects. For example:

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

### TeXlyre

TeXlyre, by itself, is simply a bunch of static html, css, and js files. While
it does work as a Typst/LaTeX editor in that form, using it to share projects
and do live modifications will require setting up more infrastructure.
See [the official TeXlyre infrastructure sample for more info](https://github.com/TeXlyre/texlyre-infrastructure).
While I have explored writing a TeXlyre module based on that sample, I've given
up because I hate DevOps and DevOps hate me. I'd be very happy to have a module
for it; I just don't have the knowledge, energy or time for it right now.
However, if you'd be interested in either using or writing it, please comment on
issue [#5](https://github.com/blokyk/packages.nix/issues/5), and I'll be happy
to reconsider it / have some new motivation.

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
