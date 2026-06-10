# Module tests

Run tests for a module using:

```sh
nix-build -A <module>.<test-name>
```

You might also want to pass `--builders ''`, since if the tests are "built" on a
remote machine, you will not see non-error logs. You can also pass
`--no-out-link` to avoid getting creating a symlink once the test passes.

To debug, add `.driverInteractive` at the end of the attribute, then run the
test vm:

```sh
nix-build -A <module>.<test-name>.driverInteractive && ./result/bin/nixos-test-driver
```
