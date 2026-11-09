# `diffnav`

A home-manager module to use and configure [diffnav](https://github.com/dlvhdr/diffnav)
using nix.

When enabled, it'll add diffnav to your PATH and write a config file for it
based on `programs.diffnav.settings`. If you set `enableGitIntegration`, it'll
also be set as the default `git diff` pager.
