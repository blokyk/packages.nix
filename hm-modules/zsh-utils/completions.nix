{ config, lib, ... }:
let
  cfg = config.programs.zsh.completion;

  mkStyle = args:
  lib.mkOption (args // {
    default = { value = args.default; };
    type = lib.types.listOf (
      lib.types.submodule {
        options = {
          value = lib.mkOption {
            type = args.type;
            default = args.default;
          };

          # translates to `-e` in the zstyle call
          dynamic = lib.mkOption {
            type = lib.types.bool;
            default = false;
            description = ''
              Whether the value of the style is a static value (false, default) or an expression that should be evaluated every time the style is queried.
              This form can be slow and should be avoided for commonly examined styles such as `menu` and `list-rows-first`.
            '';
          };

          # first context field
          widget = lib.mkOption {
            type = lib.types.str;
            default = "*";
            description = ''
              The caller's name, if completion is called from a named widget rather than through the normal completion system.
              Typically this is blank, but it is set by special widgets such as `predict-on` and the various functions in the Widget directory of the distribution to the name of that function, often in an abbreviated form.
            '';
          };

          completer = lib.mkOption {
            type = lib.types.str;
            default = "*";
            description = ''

            '';
          };
        };
      }
    );
  });
in {
  options = {
    programs.zsh.completion = {
      accept-exact = mkStyle {
        type = lib.types.either (lib.types.bool) (lib.types.str);
        description = ''
            This is tested for the default tag in addition to the tags valid for the current context.  If it is set to `true' and any of the trial matches is the same as the  string  on  the
            command line, this match will immediately be accepted (even if it would otherwise be considered ambiguous).

            When  completing  pathnames  (where  the tag used is `paths') this style accepts any number of patterns as the value in addition to the boolean values.  Pathnames matching one of
            these patterns will be accepted immediately even if the command line contains some more partially typed pathname components and these match no file under the directory accepted.

            This style is also used by the _expand completer to decide if words beginning with a tilde or parameter expansion should be expanded.  For example, if there  are  parameters  foo
            and foobar, the string `$foo' will only be expanded if accept-exact is set to `true'; otherwise the completion system will be allowed to complete $foo to $foobar. If the style is
            set to `continue', _expand will add the expansion as a match and the completion system will also be allowed to continue.
        '';
      };
    };
  };

  # config = {
  #   programs.zsh.completion = {
  #     matcher-list = [
  #       {
  #         value = "m:{a-z}={A-Z}";
  #       }
  #     ];
  #   };
  # };
}
