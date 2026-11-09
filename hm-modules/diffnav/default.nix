{ config, lib, pkgs, ... }:
let
  inherit (lib) mkEnableOption mkOption types;
  defaultPrio = lib.modules.defaultOverridePriority;

  yaml = pkgs.formats.yaml {};

  cfg = config.programs.diffnav;
  exe = lib.getExe cfg.package;

  themes = [
    "builtin_solarized_dark"
    "builtin_solarized_light"
    "catppuccin_latte"
    "catppuccin_macchiato"
    "catppuccin_mocha"
    "dimmed_monokai"
    "dracula"
    "github"
    "gruvbox_dark"
    "gruvbox_light"
    "monokai_pro"
    "neon"
    "nord"
    "one_half_dark"
    "one_half_light"
    "tokyo_night"
    "zenburn"
  ];

  icons = [
    "nerd-fonts-status"
    "nerd-fonts-simple"
    "nerd-fonts-filetype"
    "nerd-fonts-full"
    "unicode"
    "ascii"
  ];
in {
  options.programs.diffnav = {
    enable = mkEnableOption "diffnav, a git diff pager based on delta but with a file tree";
    package = lib.mkPackageOption pkgs "diffnav" { };

    enableGitIntegration = mkEnableOption "git integration for diffnav";

    settings = mkOption {
      type = types.submodule {
        freeformType = yaml.type;
        options = {
          ui = {
            hideHeader = mkOption {
              type = types.bool;
              default = false;
              description = ''
                Whether to hide the header to get more screen space for diffs.
              '';
            };

            hideFooter = mkOption {
              type = types.bool;
              default = false;
              description = ''
                Whether to hide the footer to get more screen space for diffs.
              '';
            };

            showFileTree = mkOption {
              type = types.bool;
              default = true;
              description = ''
                Whether to start with the file tree shown (toggle with 'e').
              '';
            };

            fileTreeWidth = mkOption {
              type = types.ints.positive;
              default = 26;
            };

            searchTreeWidth = mkOption {
              type = types.ints.positive;
              default = 50;
            };

            icons = mkOption {
              type = types.enum icons;
              default = "nerd-fonts-status";
              description = ''
                The icon style to use in the UI.
                Available styles:
                  - ${lib.concatStringsSep "\n  -" icons}
              '';
            };

            colorFileNames = mkOption {
              type = types.bool;
              default = true;
              description = ''
                Whether to color filenames by git status.
              '';
            };

            showDiffStats = mkOption {
              type = types.bool;
              default = true;
              description = ''
                Whether to show the amount of lines added / removed next to the file.
              '';
            };

            sideBySide = mkOption {
              type = types.bool;
              default = true;
              description = ''
                Whether to show diffs side-by-side instead of using the unified view.
              '';
            };

            startFoldersOpenDepth = mkOption {
              type = types.coercedTo
                (types.enum ["all" "none"])
                (s: { all = -1; none = 0; }.${s})
                types.int;
              default = "all";
              description = ''
                Number of levels of folders to open on startup.
                Use "all" to open all folders regardless of level, or "none" to open no folder by default.
              '';
            };

            theme = mkOption {
              type = types.enum themes;
              default = "tokyo_night";
              example = "gruvbox_dark";
              description = ''
                The ID of the theme to use.
                Available IDs are:
                  - ${lib.concatStringsSep "\n  -" themes}
              '';
            };
          };
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];
    xdg.configFile."diffnav/config.yml".source = yaml.generate "diffnav-config.yml" cfg.settings;

    programs.git.iniContent = lib.mkIf cfg.enableGitIntegration {
      pager.diff =
        # if delta is also enabled, then we have to slightly override it,
        # but we still want the user to be able to mkForce
        # (i explicitly want to allow diffnav and delta to cohabitate)
        let delta = config.programs.delta; in
        if delta.enable && delta.enableGitIntegration then
          lib.mkOverride (defaultPrio - 10) exe
        else
          exe;
    };
  };
}
