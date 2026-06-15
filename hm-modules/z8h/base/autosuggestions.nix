
{ config, lib, ... }:
let
  cfg = config.programs.z8h;
in {
  programs.zsh = lib.mkIf cfg.enable {
    autosuggestion.enable = cfg.enable;
  };
}
