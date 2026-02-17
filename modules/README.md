# zoë's nixos modules

Some NixOS modules I wrote for convenience. Currently exposes:

- [`mtlynch/picoshare`](https://github.com/mtlynch/picoshare/) as `services.picoshare`
- [`syncyomi/syncyomi`](https://github.com/syncyomi/syncyomi/) as `services.syncyomi`
- `services.hostrr`, a custom module I wrote for easily configuring my server's
  services and reverse proxy. see [the readme](./hostrr/README.md) for more info.

## Usage

Import it like any other module:

```nix
# configuration.nix
{ lib, pkgs, ... }: {
  imports = [ <zoeee/modules> ];
  ...

  services.picoshare = {
    enable = true;
    adminSecretFile = "/var/secrets/picoshare";
  };
}
```
