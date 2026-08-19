{ config, lib, pkgs, ... }:
let
  yaml = pkgs.formats.yaml {};
  cfg = config.programs.cookiecutter;
in {
  options = {
    programs.cookiecutter = {
      enable = lib.mkEnableOption "configuring cookiecutter, a project scaffolding utility, through home-manager";
      package = lib.mkPackageOption pkgs "cookiecutter" {};

      # todo: would be nice if you could just give a path to the templated directory,
      # and specify the content of `cookiecutter.json` with nix (and have other stuff
      # like hooks and stuff also come from nix).
      # (this would also make it easier to use nixified hooks!)
      cutters = lib.mkOption {
        type = lib.types.attrsOf lib.types.path;
        example = lib.options.literalExpression ''
          {
            java-shell = ./templates/java;

            pypkg = fetchFromGitHub {
              owner = "audreyfeldroy";
              repo = "cookiecutter-pypackage";
              rev = "1232467...";
              hash = "...";
            };
          }
        '';

        description = ''
          A set of cookiecutters (templates) to add to the local cookiecutter registry, which allows you to use them anytime.
          The attribute names are the names the cookiecutters will have.
        '';
      };

      settings = lib.mkOption {
        type = lib.types.submodule {
          freeformType = yaml.type;

          options = {
            cookiecutters_dir = lib.mkOption {
              type = lib.types.path;
              # default = "~/.cookiecutters"
              example = "/home/foo/.cache/cookiecutters";
              description = ''
                Directory where your cookiecutters are cloned to when you use Cookiecutter with a repo argument.
                It is also used to store templates specified with {option}`programs.cookiecutter.cutters`.
              '';
            };
          };
        };
      };
    };
  };

  config = {
    # the default value is ~/.cookiecutters, just as the vanilla program
    # note: you could argue that, by default, this should just point to a nix store
    #       directory containing the `cfg.cutters`, but cookiecutter can also be used
    #       with online repos, which it then caches to cookiecutters_dir; however, if
    #       was a folder in the store, it wouldn't be writable, thus completely
    #       disabling that feature
    programs.cookiecutter.settings.cookiecutters_dir = lib.mkOptionDefault (config.home.homeDirectory + "/.cookiecutters");

    assertions = [{
      assertion = (!lib.hasPrefix config.home.homeDirectory cfg.settings.cookiecutters_dir) -> (cfg.cutters == {});
      message = "programs.cookiecutter: `cookiecutters_dir` must be a subdirectory of `home.homeDirectory` if any `cutters` are specified.";
    }];

    home.packages = [ cfg.package ];

    home.file = lib.mkIf cfg.enable (lib.mkMerge [
      # config file
      {
        ".cookiecutterrc".source = yaml.generate "cookiecutter.yaml" cfg.settings;
      }
      # cutters
      (
        let
          relativeCuttersDir = lib.removePrefix config.home.homeDirectory cfg.settings.cookiecutters_dir;
        in
          lib.mapAttrs' (name: value: {
            name = "${relativeCuttersDir}/${name}";
            value = {
              # make a symlink to the folder directly, not to each individual file inside
              recursive = false;
              source = value;
            };
          }) cfg.cutters
      )
    ]);
  };
}
