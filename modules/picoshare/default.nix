# fixme: set pkgs.picoshare's passthru.tests.module = nixosTests.picoshare
{ config, lib, options, ... }:
with lib;
let
  opts = options.services.picoshare;
  cfg = config.services.picoshare;

  optName = name: "{option}`services.picoshare.${name}`";
in {
  options.services.picoshare = {
    enable = mkEnableOption "picoshare";
    package = mkPackageOption (import <zoeee/pkgs> {}) "picoshare" { pkgsText = "zoeee/pkgs"; };

    openFirewall = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Whether to open the firewall for the port in ${optName "port"}`.
      '';
    };

    port = mkOption {
      type = types.int;
      default = 4001;
      example = 8080;
      description = ''
        The port that PicoShare will listen on.
      '';
    };

    behindReverseProxy = mkOption {
      type = types.bool;
      default = false;
      example = true;
      description = ''
        Set to `true` for better logging when PicoShare is running behind a reverse proxy.
      '';
    };

    adminPasswordFile = mkOption {
      type = types.externalPath;
      example = "/var/secrets/picoshare";
      description = ''
        String containing the path to the file containing the admin passphrase. This is read by systemd, so you can set the tighest permissions you need (e.g. root only).

        It must *NOT* be a path literal, since it would otherwise be stored in the nix store, which would make the secrets readable by anyone.
      '';
    };

    user = mkOption {
      type = types.str;
      default = "picoshare";
      example = "jane";
      description = ''
        User account under which PicoShare will run.
      '';
    };

    group = mkOption {
      type = types.str;
      default = "picoshare";
      example = "medias";
      description = ''
        Group under which PicoShare will run.
      '';
    };
  };

  config = let
    hasCustomUser  = cfg.user != opts.user.default;
    hasCustomGroup = cfg.group != opts.group.default;
  in
    mkIf cfg.enable {
      users.users = mkIf (!hasCustomUser) {
        "picoshare" = {
          name = "picoshare";
          group = cfg.group;
          isSystemUser = true;
        };
      };

      users.groups = mkIf (!hasCustomGroup) {
        "picoshare" = { };
      };

      networking.firewall.allowedTCPPorts = mkIf cfg.openFirewall [ cfg.port ];

      systemd.services.picoshare = {
        description = cfg.package.meta.description or
          "A minimalist, easy-to-host service for sharing images and other files.";

        wantedBy = [ "multi-user.target" ];
        after = [ "network.target" ];

        environment = {
          PORT = toString cfg.port;
        };

        script = ''
          export PS_SHARED_SECRET="$(systemd-creds cat adminPass)";
          ${lib.getExe cfg.package} -db "''${STATE_DIRECTORY}/data.db";
        '';

        serviceConfig = {
          User = cfg.user;
          Group = cfg.group;

          StateDirectory = "picoshare";
          LoadCredential = "adminPass:${cfg.adminPasswordFile}";

          DynamicUser = !hasCustomUser;
        };
      };

      # todo: add (optional) vacuuming service
    };

  meta = {
    maintainers = [ (import ../../maintainers.nix).blokyk ];
    # doc = ./README.md;
  };
}