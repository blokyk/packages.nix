{ config, ... }: {
  programs.zsh.siteFunctions."-z4h-compinit-impl" = config.programs.zsh.completionInit;
}
