{ config, lib, pkgs, ... }:
let
  cfg = config.programs.zsh.fzf;
in {
  options = {
    programs.zsh.fzf = {
      enable = lib.mkEnableOption "fzf integration for zsh";
      package = lib.mkPackageOption pkgs "fzf" {};
    };
  };

  config = {
    programs.zsh = {
      fzf.enable = lib.mkOptionDefault config.programs.z8h.enable;
    };
  };
}
