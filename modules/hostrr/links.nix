{ lib, ... }:
with lib.options;
with lib.types;
let
  example = import ./examples.nix;

  # return a merged mkIf
  mkIfElse =
    cond: thenVal: elseVal:
    with lib;
    mkMerge [
      (mkIf cond thenVal)
      (mkIf (!cond) elseVal)
    ];
in
mkOption {
  description = "A list of short-link that should redirect to a file or another url.";
  default = { };
  example = example;
  type = attrsOf (
    submodule (
      { config, ... }:
      {
        options = {
          file = mkOption {
            type = nullOr path;
            default = null;
            example = /var/www/shared/robots.txt;
            description = "The path of the file that should be served.";
          };

          content-type = mkOption {
            type = nullOr str;
            default = null;
            example = "audio/ogg";
            description = "The MIME type of the served file.";
          };

          url = mkOption {
            type = nullOr str;
            default = null;
            example = "https://my.other.site";
            description = "The URI to redirect this link to. This can be a URL or another location of this host.";
          };

          # a `services.nginx.virtualHost.location` configuration
          #
          # used so that links can configure themselves and the parent host
          # just need to collect this option's value and do `location.<link.name> = link._location-config`
          _location-config = mkOption {
            type = nullOr attrs;
            visible = false;
          };
        };

        config = {
          # assertions = with cfg; [{
          #   # either the url is set OR the file/content-type is set, but not both
          #   assertion = lib.xor (url == null) (file == null && content-type == null);
          #   message = ''
          #     You can only specify a `url` to redirect to OR a `file` to serve, but not both at the same time (nor neither, ya gotta serve *something*).
          #   '';
          # }];

          _location-config =
            with config;
            mkIfElse (file != null)
              # then (if it's a file link)
              {
                alias = file;
                tryFiles = "$uri =404";

                # set content-type (and add charset=utf-8 if it's plain text)
                extraConfig =
                  lib.optionalString (content-type != null) "types { } default_type ${content-type};\n"
                  + lib.optionalString (content-type == "text/plain") "charset utf-8;\n";
              }
              # else (if it's a url link)
              {
                return = ''
                  301 ${url}
                '';
              };
        };
      }
    )
  );
}
