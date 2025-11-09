{ config, home, lib, pkgs, ... }:

let
    cfg = config.programs.zsh-powerlevel10k;
    mkTheme = import ./mkTheme.nix;

    builtin-themes = import ./builtin-themes.nix;
    builtin-formatters = import ./builtin-git-formatters.nix;

    # format strings ["foo", "bar", "baz"] as:
    # ''
    # - `foo`
    # - `bar`
    # - `baz
    # ''
    mkMDList = vals: lib.join "\n- " (map (m: "`" + m + "`") vals);
in
with lib; {
    options.programs.zsh-powerlevel10k = {
        enable = mkEnableOption "zsh-powerlevel10k";

        package = mkPackageOption pkgs "zsh-powerlevel10k" {};

        promptInit = mkOption {
            type = types.lines;
            default = ''
                source ${cfg.package}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
                source "$POWERLEVEL9K_CONFIG_FILE"
            '';
            description = "The command that is ran to inject p10k into the prompt and initialize it";
        };

        themeFile = mkOption {
            type = types.nullOr types.path;
            default = null;
            example = literalExpression "home.programs.zsh.dotDir + \"/.p10k.zsh\"";
            description = ''
                Path to the p10k theme file (generally called `.p10k.zsh`).
                If this is set, then the `theme.*` options are ignored.
            '';
        };

        theme = mkOption {
            type = types.submoduleWith {
                modules = [
                    ({ config, ... }: import ./theme-options.nix {inherit lib mkMDList config;})
                    ({ config, ...}: import ./element-options.nix {inherit lib config;})
                ];
            };
            default = { };
            description = literalMD ''
                The set of options defining the prompt theme. A few pre-defined themes
                are available under the `config.programs.zsh-powerlevel10k.themes` attr-set:
                ${mkMDList (builtins.attrNames builtin-themes)}
            '';
        };

        extraConfig = mkOption {
            type = types.lines;
            default = "";
            example = ''
                echo "p10k.zsh read"
            '';
            description = "Extra configuration to append at the very end of `p10k.zsh`";
        };

        themes = mkOption {
            visible = "shallow";
            readOnly = true;
            default = builtin-themes;
            description = literalMD ''
                A list of pre-defined basic themes. *This value is read-only.*
                Available values:
                ${mkMDList (builtins.attrNames builtin-themes)}
            '';
        };

        git-formatters = mkOption {
            visible = "shallow";
            readOnly = true;
            default = builtin-formatters;
            description = literalMD ''
                A list of pre-defined git formatters. *This value is read-only.*
                Available values:
                ${mkMDList (builtins.attrNames builtin-formatters)}
            '';
        };
    };

    config = mkIf cfg.enable {
        home = {
            packages = [ cfg.package ];
        };

        programs.zsh.initContent = mkAfter cfg.promptInit;

        programs.zsh.envExtra =
            let
                themeFile = if (cfg.themeFile == null)
                    then pkgs.writeText ".p10k.zsh" (mkTheme { inherit lib; config = cfg; })
                    else cfg.themeFile;
            in
                mkAfter ''
                    export POWERLEVEL9K_DISABLE_CONFIGURATION_WIZARD=true
                    export POWERLEVEL9K_CONFIG_FILE="${toString themeFile}"
                '';
    };
}