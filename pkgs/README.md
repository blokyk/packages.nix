# zoë's nix packages

A few nix packages I wrote (surprise!). Currently available:

- [`mtlynch/picoshare`](https://github.com/mtlynch/picoshare/), a minimal
  self-hostable file-sharing service
- [`blokyk/nix-otel`](https://github.com/blokyk/nix-otel), and updated fork of
  [`lf-/nix-otel`](https://github.com/lf-/nix-otel)
- [`TeXlyre/TeXlyre`](https://github.com/texlyre/texlyre), a self-hostable
  LaTeX and typst web editor

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

    # since `lib` isn't specified, it'll use `mynix.lib`
    zpkgs = import <zoeee/pkgs> { pkgs = mynix; };
in { ... }
```
