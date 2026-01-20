{ config, lib, options, pkgs, ... }:
let
  inherit (lib)
    filterAttrs filterAttrsRecursive
    getExe
    mkIf mkDefault
    mkEnableOption mkOption mkPackageOption
    types;

  toml = pkgs.formats.toml {};

  opts = options.services.syncyomi;
  cfg = config.services.syncyomi;

  secretEnvName = "SYNCYOMI_SESSION_SECRET";
  defaultLogFilePath = "/var/log/syncyomi/syncyomi.log";

  optName = name: "{option}`services.syncyomi.${name}`";
in {
  options.services.syncyomi = {
    enable = mkEnableOption "Synchronize Tachiyomi forks across multiple devices";
    package = mkPackageOption pkgs "syncyomi" { };

    openFirewall = mkOption {
      type = types.bool;
      default = false;
      description = ''
        Whether to open the firewall for the port in ${optName "port"}`.
      '';
    };

    user = mkOption {
      type = types.str;
      default = "syncyomi";
      example = "services";
      description = ''
        User account under which Syncyomi will run.
      '';
    };

    group = mkOption {
      type = types.str;
      default = "syncyomi";
      example = "medias";
      description = ''
        Group under which Syncyomi will run.
      '';
    };

    settings = mkOption {
      description = ''
        Settings for SyncYomi, which end up in the config.toml file.
        Note: this is a TOML freeform option, meaning you can also specify SyncYomi options which are not explicitly supported by this module.
      '';
      example = {
        port = 4587;
        logMaxSize = 100;
        checkForUpdates = false;
        DatabaseType = true;
      };

      type = types.submodule (
        { options, ... }: {
          freeformType = toml.type;
          options = {
            host = mkOption {
              type = types.str;
              default = "localhost";
              example = "0.0.0.0";
              description = ''
                The hostname that Syncyomi will listen on.
              '';
            };

            port = mkOption {
              type = types.port;
              default = 8282;
              example = 9876;
              description = ''
                The port that Syncyomi will listen on.
              '';
            };

            # todo: add postgresql options/support
            # for changes to the service & systemd config, see miniflux's module

            baseUrl = mkOption {
              type = types.str;
              default = "/";
              example = "/SyncYomi/";
              description = ''
                Set custom base URL, useful when running behind a reverse proxy for a single domain.
                If accessible with an open firewall or running on a subdomain, this should probably be the default: '/'.
                If it is set, you will need to rewrite every incoming request to remove the prefix (see syncyomi docs for more info).
              '';
            };

            writeLogFile = mkEnableOption "SyncYomi logging" // {
              description = ''
                Whether SyncYomi should write logs to ${dirOf defaultLogFilePath}/.
                If false (the default), writes to stdout instead.
                If true, writes logs to ${defaultLogFilePath}
              '';
            };

            # we have to declare this because freeform options cannot depend on other options in the same module
            # BUT if we declare both options then it's fine. it's a little annoying since it's also a legit
            # option that some users may set (despite it being broken in this state).
            logPath = mkOption {
              type = types.nullOr types.str;
              default = null;
              visible = false;
              description = ''
                The file that SyncYomi will write logs to.
                Generally, you shouldn't set this, and instead set ${optName "settings.writeLogFile"} to `true`.
                Manually setting this isn't supported (but if you do, you'll probably want to set [option]`systemd.services.syncyomi.serviceConfig.ReadWritePaths` and other related options.)
              '';
            };

            logLevel = mkOption {
              type = types.enum [ "ERROR" "DEBUG" "INFO" "WARN" "TRACE" ];
              default = "DEBUG";
              example = "ERROR";
              description = ''
                The minimum log level to use.
              '';
            };

            logMaxSize = mkOption {
              type = types.ints.positive;
              default = 50;
              example = 10;
              description = ''
                Maximum log size in megabytes.
              '';
            };

            logMaxBackups = mkOption {
              type = types.ints.positive;
              default = 3;
              example = 10;
              description = ''
                Maximum amount of old log files to keep.
              '';
            };

            checkForUpdates = mkOption {
              type = types.bool;
              default = true;
              example = false;
              description = ''
                Whether to allow SyncYomi to automatically check for updates.
              '';
            };

            # not a real upstream option, used to replace `sessionSecret`:
            # we take the file path here, then use sed/envsubst to replace
            # the value in the file file
            sessionSecretFile = mkOption {
              type = types.externalPath;
              example = "/var/secrets/syncyomi";
              description = ''
                String containing the path to the file containing the session key, used to secure the internal cookie store.
                This is read by systemd, so you can set the tighest permissions you need (e.g. root only).

                It must *NOT* be a path literal, since it would otherwise be stored in the nix store, which would make the secrets readable by anyone.
              '';
            };

            sessionSecret = mkOption {
              type = types.str;
              description = ''
                Placeholder replaced at runtime with real secret from [options]`services.syncyomi.settings.sessionSecretFile`.
                Do not use or set this option.
              '';
              # not readonly cause then users wouldn't see assertion,
              # just an error about the option already being defined
              #readOnly = true;
              visible = false;
              internal = true;
              # set the `sessionSecret` field to SYNCYOMI_SESSION_SECRET, so it'll
              # be substituted at runtime by our systemd service
              # we always override this because the user should/will never set this
              default = "$" + secretEnvName;
            };

            # used to store the file text of the config
            _confPath = mkOption {
              type = types.anything;
              internal = true;
              visible = false;
              readOnly = true;
            };
          };

          # set logPath to /var/log/syncyomi/ if file logging is enabled
          config.logPath =
            mkIf cfg.settings.writeLogFile
              (mkDefault defaultLogFilePath);

          config.assertions = [
            {
              assertion = cfg.settings.sessionSecret != options.sessionSecret.default;
              message = ''
                For security reasons, do not set services.syncyomi.settings.sessionSecret directly, or it'll be readable by anyone.
                Instead, set sessionSecretFile to point to a file containing the secret.
              '';
            }
          ];

          config._confPath = mkIf cfg.enable (
            let
              # don't generate the synthetic/special options
              isRealOption =
                name: value:
                  name != "writeLogFile" &&
                  name != "sessionSecretFile" &&
                  name != "assertions" &&
                  name != "_confPath";

              onlyRealSettings = filterAttrs isRealOption cfg.settings;
              onlyNonNullSettings = (filterAttrsRecursive (_: val: val != null) onlyRealSettings);
            in
              toml.generate "config.toml" onlyNonNullSettings
          );
        }
      );
    };
  };

  config =
    let
      hasCustomUser  = cfg.user  != opts.user.default;
      hasCustomGroup = cfg.group != opts.group.default;
    in
      mkIf cfg.enable {
        networking.firewall.allowedTCPPorts = mkIf cfg.openFirewall [ cfg.settings.port ];

        users.users = mkIf (!hasCustomUser) {
          "${cfg.user}" = {
            name = "${cfg.user}";
            group = cfg.group;
            isSystemUser = true;
          };
        };

        users.groups = mkIf (!hasCustomGroup) {
          "${cfg.group}" = { };
        };

        systemd.services.syncyomi = {
          description = "Synchronize Tachiyomi across multiple devices.";

          wantedBy = [ "multi-user.target" ];
          wants = [ "network-online.target" ];
          after = [ "network-online.target" ];

          # replace the value of the secret before starting the app
          script = ''
            env - ${secretEnvName}="$(cat ${cfg.settings.sessionSecretFile})" \
              ${getExe pkgs.envsubst} -no-unset -no-empty \
                -i "${cfg.settings._confPath}" \
                -o "''${STATE_DIRECTORY}/config.toml"
            ${getExe cfg.package} --config "''${STATE_DIRECTORY}"
          '';

          serviceConfig = {
            User = cfg.user;
            Group = cfg.group;
            DynamicUser = !hasCustomUser;

            StateDirectory = "syncyomi";
            RuntimeDirectory = "syncyomi";
            LogsDirectory = "syncyomi";

            Type = "simple";
            Restart = mkDefault "on-failure";
            RestartSec = mkDefault 5;

            ReadOnlyPaths = [ cfg.settings.sessionSecretFile ];

            LockPersonality = true;
            NoNewPrivileges = true;
            PrivateDevices = true;
            PrivateMounts = true;
            PrivateTmp = true;
            PrivateUsers = true;
            ProcSubset = "pid";
            ProtectClock = true;
            ProtectControlGroups = true;
            ProtectHome = true;
            ProtectKernelLogs = true;
            ProtectKernelModules = true;
            ProtectKernelTunables = true;
            ProtectProc = "invisible";
            ProtectSystem = "strict";
            RestrictAddressFamilies = [
              "AF_UNIX"
              "AF_INET"
              "AF_INET6"
              "AF_NETLINK"
            ];
            RestrictNamespaces = "yes";
            RestrictRealtime = true;
            RestrictSUIDSGID = true;
            SystemCallArchitectures = "native";
            SystemCallFilter = [
              "@system-service"
              "~@privileged"
            ];
          };
        };
      };
}