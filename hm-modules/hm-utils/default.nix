{ lib, ... }: {
  imports = [
    ./diff-on-activation.nix
  ];

  meta.maintainers = with lib.maintainers; [ blokyk ];
}
