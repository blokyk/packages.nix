# z8h

zsh8humans (z8h) is a home-manager-based turnkey configuration for zsh, mostly
adapted (stolen) from [`romkatv/zsh4humans`](https://github.com/romkatv/zsh4humans).

The goal is to strip down zsh4humans to only its configuration part, without
the config/package-management part it inevitably had to implement, since almost
all of the heavy lifting there can be done by home-manager and nix. This allows
being fully declarative, in alignement with the nix philosophy, instead of
having a bunch of individual commands thrown haphazardly in a `.zshrc`. If you
use nix, and especially home-manager, I imagine you agree with that philosophy
:)

Currently, I'm doing my best to work through the different scripts and functions
that come with zsh4humans, so that I can at least get a solid basic
configuration. Further customizability might come later in some cases, though it
is notable that a lot of what zsh4humans does is make zsh more palatable to
customize (such as the `z4h bindkey` command, which is currently `programs.z8h.keybindings`)
and then use those abstractions to configure zsh, so it's possible some of this
will just get split/migrated into the `zsh-utils` module, so everyone can
benefit from it without dealing with the rest of z8h's changes.

Mac support is not currently planned, since I don't own one to test it on. If
you want to help with the effort, though, I'd appreciate if you'd show interest
by opening an issue or PR to work through what changes would be needed.
