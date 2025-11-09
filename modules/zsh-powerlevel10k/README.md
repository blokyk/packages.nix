# zsh-powerlevel10k

A home-manager module for configuring `powerlevel10k` directly in nix.

TODO: rewrite this to use derivations to make it nixos- vs home-manager-agnostic.
either:

  1. turn mkTheme into a derivation whose definition depends on the rest of the
  config, OR make it into a function that takes in the theme (not a good idea
  cause no type checking for free)
  2. rewrite the prompt injection logic to handle both cases (less fun)
