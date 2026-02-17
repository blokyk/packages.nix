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

## issues & features

see the [issues tab](https://github.com/blokyk/packages.nix/issues) for a list
of known issues i'd like to fix and features i'd love to add.

please note that an issue being old and/or comment-less does not mean i'm not
interested in fixing it! since i use this repo myself and have some
time/priority constraints, i tend to mostly just do what works for me on
personal projects, because they basically never get any outside attention.
however, if you're using this a package or module from this repo, i'd be happy
to fix any bug or missing feature you may encounter, so feel free to open an
issue, or comment on an existing one (and mention me if you do!).

however, please write your issue yourself. i'd prefer reading a clunky, concise
bug report, or unclear feature request, rather than the 5-paragraph *pavés* of
ai-generated slop i've encountered before.

## contributing

just like issues, feel free to open a pr if you have any fix or feature you'd
like to contribute back. even if you're not sure it would fit here or if it's
quite correct, i'd be happy to help you push it over the finish line :)

please note that, just like issues, this repo will only be accepting
human-generated code/documentation. again, mid code/docs that had a creation
and thought process behind them are easier to deal with and fix than statistical
noise. not respecting this rule will get your pr closed without debate, sorry.

## license

unless otherwise specified, all code in this repository is licensed under the
MIT license.
