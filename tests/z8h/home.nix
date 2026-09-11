{ config, lib, pkgs, ... }: {
  imports = [ ../../hm-modules/z8h ];

  programs.z8h = {
    enable = true;
  };
}
