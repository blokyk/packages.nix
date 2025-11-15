# `picoshare`

A NixOS module for managing a [`picoshare`](https://github.com/mtlynch/picoshare/)
instance, a minimalist, easy-to-host service for sharing images and other files.

Among the available options, if you enable the service, you *must* specify the
admin credentials, by setting `services.picoshare.adminPasswordFile`. This
value must be **a string containing the path** to the file. You cannot use a
path literal or path object, as that would put your secrets into the nix store,
which anyone and anything can read.

Refer to [the original README](https://github.com/mtlynch/picoshare/blob/master/README.md)
for more info.

## Cleaning up the database

TODO: cf [issue #6](https://github.com/blokyk/packages.nix/issues/6)

(Also please scream at me (i.e. mention me) in an issue to add a list of options
here; I do think good doc is important I just don't have the time :| in the mean
time, you can check [the source code](./default.nix), it already has doc strings
for each options. If you want to submit a PR for this, I'd be *very* grateful!)
