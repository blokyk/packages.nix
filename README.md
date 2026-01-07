# `<zoeee>`

hey y'all, this is just a small nix channel i made to have a clear place to
put all my nix packaging little things, instead of spreading them across a
million git repos and then having to manage submodules and stuff (which i
hate...).

> [!NOTE]
> since i dont use flakes on my system right now, the flake support of this
> repo might break or be outdated without me noticing. if that's the case,
> please don't hesitate to open an issue!

because i don't want to have to rigorously maintain them, i don't really plan
on upstreaming any of these to nixpkgs right now. however, if you want to
adopt (i.e. act as nixpkgs maintainer) any of them, feel free to reach out,
it'd make me incredibly happy :D

## usage

first, add this channel to your profile:

```sh
nix-channel --add 'https://github.com/blokyk/packages.nix/archive/main.tar.gz' zoeee
```

if you want to use this for your system, you'll need to add `sudo` in front of
that command, so that you can import it in `/etc/nixos/configuration.nix`.

this channel is split up into three components, each of which has its own
`README.md` to document it. briefly:

- [`<zoeee/pkgs>`](./pkgs/README.md) -- contains some nix packages i wrote/stole.
  you can just import it as an attrset which contains each derivation/package:

  ```nix
  # in configuration.nix, or a project's default.nix
  { ... }:
  let
    # you can also use `callPackage` if you want, we just use import for simplicity
    zpkgs = import <zoeee/pkgs> {}; # or (import <zoeee> {}).pkgs
  in {
    environment.systemPackages = [
        zpkgs.picoshare
    ];
  }
  ```

- [`<zoeee/modules>`](./modules/README.md) -- contains some **NixOS** modules.
  import it as you would any other module, in a top-level scope imports list:

  ```nix
  # configuration.nix
  { ... }: {
    imports = [ <zoeee/modules> ];

    ...
  }
  ```

- [`<zoeee/hm-modules>`](./hm-modules/README.md) -- contains some
  **`home-manager`** modules. import it into your `home.nix` file or equivalent:

  ```nix
  # home.nix
  { pkgs, ... }: {
    imports = [ <zoeee/hm-modules> ];

    programs.zsh-powerlevel10k.enable = true;
  }
  ```

Read the README of each of these to see the available packages and modules, as
well as more details about the installation/usage.
