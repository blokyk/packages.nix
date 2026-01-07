# zoë's nix packages

A few nix packages I wrote (surprise!). Currently available:

- [`mtlynch/picoshare`](https://github.com/mtlynch/picoshare/)
- [`blokyk/nix-otel`](https://github.com/blokyk/nix-otel) (updated fork of
  [`lf-/nix-otel`](https://github.com/lf-/nix-otel))

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

If needed, you can also pass specific `nixpkgs`, `lib` or `pkgs` objects. For
example:

```nix
let
    mynix = import <mynix> {};
    mypkgs = mynix.pkgs // {
        buildGoModule =
            abort "no Golang in this wholesome christian minecraft server";
    };

    # since `lib` isn't specified, it'll use `mynix.lib`
    zpkgs = import <zoeee/pkgs> { nixpkgs = mynix; pkgs = mypkgs; };
in { ... }
```
