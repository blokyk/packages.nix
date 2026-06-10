# zoë's `home-manager` modules

A small collection of *`home-manager`* modules I wrote. Each module has its
documentation in its own folder's README:

- [`hm-utils`](./hm-utils/README.md)
- [`ringboard`](./ringboard/README.md)
- [`z4h`](./z4h/README.md)
- [`zsh-patina`](./zsh-patina/README.md)
- [`zsh-powerlevel10k`](./zsh-powerlevel10k/README.md)
- [`zsh-utils`](./zsh-utils/README.md)

There is also a special utility "module" in [`mk-keybindings`](./mk-keybindings/README.md),
mostly useful for module authors; check its documentation for more info.

## Usage

These modules are written to be imported inside the user declaration:

- with a standalone home-manager installation, this is the file `home.nix`, so
  you'd write:

  ```nix
  # home.nix
  { ... }: {
    imports = [ <zoeee/hm-modules> ];

    programs.zsh-powerlevel10k = { ... };
  }
  ```

- with a nixos-module home-manager installation, you import it similarly in
  your user declaration in `configuration.nix`:

  ```nix
  { ... }: {
    imports = [ <home-manager/nixos> ];

    home-manager.users.blokyk = { ... }: {
        imports = [ <zoeee/hm-modules> ];
        ...
    };
  }
  ```

If you'd like to see a real-life example, you can look at my config's
[`blokyk.nix`](https://github.com/blokyk/naqi.nix/tree/f682e2fa05b9c72457b6ac975cefa08b881139de/users/blokyk.nix)
and [`blokyk/home.nix`](https://github.com/blokyk/naqi.nix/tree/f682e2fa05b9c72457b6ac975cefa08b881139de/users/blokyk/home.nix) files.
