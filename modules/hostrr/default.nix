{ config, lib, pkgs, ... }:
with lib.options; with lib.types;
let
  cfg = config.services.hostrr;
  examples = import ./examples.nix;

  linksOpt = import ./links.nix { inherit lib pkgs config; };
  mkHostConfig = import ./mkHostConfig.nix { inherit lib pkgs config; };
in {
  options.services.hostrr = {
    enable = mkEnableOption "hostrr";

    enableHTTPS = mkOption {
      type = enum [true false "both"];
      default = false;
      example = true;
      description = ''
        Whether *all* the managed domains/subdomains should use HTTPS/SSL.
        Each hosts also has a [option]`services.hostrr.hosts.<name>.enableSSL` option
        if you need to set each individually.

        Can be true (forces HTTPS), false (forces HTTP), or 'both' (allows both).
      '';
    };

    base = mkOption {
      type = str;
      example = "example.com";
      description = "The base domain name to put subdomains under.";
    };

    hosts = mkOption {
      description = "The list of subdomains/hosts and their config.";
      default = { };
      example = examples.hosts;
      type = attrsOf (submodule {
        options = {
          # all declared hosts are enabled by default (cause it's annoying/verbose otherwise)
          enable = mkOption {
            type = bool;
            description = "Whether to enable this subdomain/host.";
            default = true;
            example = false;
          };

          enableHTTPS = mkOption {
            type = enum [true false "both"];
            # default = cfg.enableHTTPS;
            example = true;
            description = ''
              Whether the subdomain should use HTTPS/SSL.

              Can be true (forces HTTPS), false (forces HTTP), or 'both' (allows both).
            '';
          };

          links = linksOpt;

          host = mkOption {
            # make sure the host doesn't end with a trailing slash
            type = addCheck str (s: !(lib.hasSuffix "/" s));
            default = "http://localhost";
            example = "http://new.site";
            description = ''
              The URL/address of the host the original service is hosted on.

              This MUST NOT end with a trailing slash, or include the port (use [option]`services.hostrr.hosts.<name>.port` for that).
            '';
          };

          port = mkOption {
            type = nullOr int;
            default = null;
            example = 12345;
            description = "The port is original service is listening on.";
          };

          maxUpload = mkOption {
            type = either str int;
            default = "1m";
            example = "100m";
            description = ''
              The maximum request/payload size that will be allowed to be sent to this host. Set to 0 to disable the limit.
              Can be an int (in bytes) or string suffixed with either 'k' (kilobytes) or 'm' (megabytes).

              You generally need to increase this for services that accept potentially large uploads (e.g. immich).
            '';
          };

          timeout = mkOption {
            type = either str int;
            default = 60;
            example = 600;
            description = ''
              The maximum time the proxied service can spend processing a request before nginx forcefully closes the connection.
              Can be an int (in seconds) or a string suffixed 'ms' (milliseconds), 's' (seconds), or 'm' (minutes).
            '';
          };

          extraConfig = mkOption {
            type = lines;
            default = "";
            description = "Extra nginx configuration to add to the root location declaration";
          };
        };

        config.enableHTTPS = lib.mkOptionDefault cfg.enableHTTPS;
      });
    };
  };

  config.assertions =
    let
      assertAtLeastPortOrLink = cfg: {
            assertion = (!cfg.enable) || (cfg.port != null) || (cfg.links != {});
            message = ''
              You have to either specify a service's port to proxy to, or a list of short links to serve/redirect (or both)
            '';
          };
    in
      map assertAtLeastPortOrLink (lib.attrValues cfg.hosts)
    ;

  config.services.nginx = lib.mkIf cfg.enable {
    enable = true;

    virtualHosts =
      lib.mapAttrs'
        (hostName: hostConfig: {
          name = if hostName == "." then cfg.base else hostName + "." + cfg.base;
          value = mkHostConfig hostConfig;
        })
        cfg.hosts;
  };

  meta = {
    maintainers = [ (import ../../maintainers.nix).blokyk ];
  };
}