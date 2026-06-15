{ config, pkgs, ... }:
let
  inherit (builtins) attrNames filter listToAttrs readDir stringLength substring;
  hasPrefix = pre: str: substring 0 (stringLength pre) str == pre;
  pipe = builtins.foldl' (x: f: f x);

  getExe = pkg: pkg + "/bin/${pkg.meta.mainProgram or pkg.pname or pkg.name}";

  genAttrs' = xs: f: listToAttrs (map f xs);

  files =
    filter
      # don't import files that start with '-' (nor default.nix (obviously))
      (f: f != "default.nix" && f != "list.nix")
      (attrNames (readDir ./.));

  substituteZsh = txt: ''
    #!${pkgs.zsh}/bin/zsh

    ${txt}
  '';

  substitutePackages = builtins.replaceStrings
    [
      "@FZF_BIN@"
    ]
    [
      (getExe config.programs.zsh.fzf.package)
    ];
in
genAttrs'
  files
  (f: {
    name  = f;
    value = pipe (builtins.readFile (./. + ("/" + f))) [
      substituteZsh
      substitutePackages
    ];
  })

