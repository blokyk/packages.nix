# zoë's nixos modules

Some NixOS modules I wrote for convenience. Currently exposes:

- [`mtlynch/picoshare`](https://github.com/mtlynch/picoshare/) as `service.picoshare`

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
