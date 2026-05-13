# `zsh-utils`

A few more knobs for configuring zsh with home-manager.

## `programs.zsh.initBlocks`

Similar to the built-in `programs.zsh.initContent` option, but allows declaring
separate [DAG blocks](https://nix-community.github.io/home-manager/index.xhtml#sec-option-types-dag)
that can have ordering dependencies. This prevents one from having to track and
tweak `mkOrder` calls in a complex config.

A toy example is attached to [the option declaration](./zsh-blocks.nix). The
[`z4h`](../z4h) module makes extensive use of these blocks for ordering various
parts of the final config.

> [!NOTE]
> Unfortunately, this obviously cannot integrate with existing uses of
> `initContent` in modules you don't write. Those other modules just use
> classic `mkAfter` and `mkBefore` calls. By default, the result of all declared
> blocks of `initBlock` will have the default order (1000), which means they
> will be sandwhiched between `initContent = mkBefore/mkafter` definitions.

## `programs.zsh.hooks.<hook>`

Allows you to declare **functions** to run for each zsh hook. These _have_ to be
functions, and cannot just be raw script code.

<!-- TODO: allow declaring hooks directly with code instead of having to
separately declare a function and then use the name of the function here -->

The available hook names are:
- `chpwd`
- `precmd`
- `preexec`
- `periodic`
- `zshaddhistory`
- `zshexit`
- `zsh_directory_name`

See `zshmisc(1)`, section "SPECIAL FUNCTIONS", header "Hook Functions" for more
information. Also see `zshexpn(1)`, section "FILENAME EXPANSION", header
"Dynamic named directories" for the behaviour of `zsh_directory_name`
specifically.
