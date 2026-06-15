{ config, lib, ... }:
let
  cfg = config.programs.z8h;
in {
  programs.zsh.completionInit = lib.mkIf cfg.enable ''
    autoload -U compinit && compinit
    autoload -Uz bashcompinit && bashcompinit
  '';

  # todo: create a zstyle option instead
  programs.zsh.initBlocks = lib.mkIf cfg.enable {
    completion-styles = lib.hm.dag.entryAfter [ "z4h-prelude" ] ''
      zstyle ':completion:*'               matcher-list      "m:{a-z}={A-Z}"
      zstyle ':completion:*'               menu              "false"
      zstyle ':completion:*'               verbose           "true"
      zstyle ':completion:::::'            insert-tab        "pending"
      zstyle ':completion:*:-subscript-:*' tag-order         "indexes parameters"
      zstyle ':completion:*:-tilde-:*'     tag-order         "directory-stack" "named-directories" "users"
      zstyle ':completion:*'               squeeze-slashes   "true"
      zstyle ':completion:*:rm:*'          ignore-line       "other"
      zstyle ':completion:*:kill:*'        ignore-line       "other"
      zstyle ':completion:*:diff:*'        ignore-line       "other"
      zstyle ':completion:*:rm:*'          file-patterns     "*:all-files"
      zstyle ':completion:*:paths'         accept-exact-dirs "true"
      zstyle ':completion:*'               single-ignored    "show"
      zstyle ':completion:*:functions'     ignored-patterns  "-*|_*"
      zstyle ':completion:*:parameters'    ignored-patterns  \
        "_(z4h|p9k|_p9k|POWERLEVEL9K|gitstatus|GITSTATUS|zsh_highlight|zsh_autosuggest|ZSH_HIGHLIGHT|ZSH_AUTOSUGGEST)*"

      if (( ! _z4h_dangerous_root )); then
        zstyle ':completion:*'             use-cache         "true"
        zstyle ':completion:*'             cache-path        "''${XDG_CACHE_HOME:-/tmp}/zcompcache-$ZSH_VERSION"
      fi

      zstyle ':completion:*:ssh:argument-1:*'                    sort             'true'
      zstyle ':completion:*:scp:argument-rest:*'                 sort             'true'

      zstyle ':completion:*:git-*:argument-rest:heads'           ignored-patterns '(FETCH_|ORIG_|*/|)HEAD'
      zstyle ':completion:*:git-*:argument-rest:heads-local'     ignored-patterns '(FETCH_|ORIG_|)HEAD'
      zstyle ':completion:*:git-*:argument-rest:heads-remote'    ignored-patterns '*/HEAD'
      zstyle ':completion:*:git-*:argument-rest:commits'         ignored-patterns '*'
      zstyle ':completion:*:git-*:argument-rest:commit-objects'  ignored-patterns '*'
      zstyle ':completion:*:git-*:argument-rest:recent-branches' ignored-patterns '*'
    '';

    bashcompinit = lib.hm.dag.entryAfter [ "completion-styles" ] ''
      # Make it possible to use completion specifications and functions written for bash.
      autoload -Uz bashcompinit
      bashcompinit
    '';
  };
}
