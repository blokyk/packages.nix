# `hm-utils`

A module of loose generic utilities that integrate with home-manager.

## `diff-on-activation`

Setting `programs.home-manager.diff-on-activation.enable` to true will add a
new step when activating (switch to) a new home-manager generation, which
displays a diff (computed by [`isabelroses/lix-diff`](https://github.com/isabelroses/lix-diff))
of significant changes compared to the previous generation. This currently does
not include configuration changes that don't change the list of packages in the
generation's closure (or the version of one of these packages).

This can be particularly useful to see the impact of adding or removing a
package on the closure size, or to see what package upgrades are being done
after bumping dependencies such as nixpkgs (or `zoeee/pkgs` ;)

By default, if the activation script is ran in a tty (i.e. in a normal terminal,
"interactively"), then it'll ask for confirmation if any changes are detected.
If the user refuses, then the activation is cancelled before any state is
changed. You can remove this confirmation step by setting
`programs.home-manager.diff-on-activation.ask-for-confirmation` to false.
