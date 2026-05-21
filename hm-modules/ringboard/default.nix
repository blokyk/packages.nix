{ config, lib, pkgs, ... }:
let
  cfg = config.services.ringboard;
in
{
  options.services.ringboard = {
    client.package = lib.mkPackageOption pkgs "ringboard" {
      extraDescription = ''
        The package that will be added to the user's environment to allow them to examine the clipboard history.
      '';
    };

    x11 = {
      enable = lib.mkEnableOption "X11 support for Ringboard";
      package = lib.mkPackageOption pkgs "ringboard" { };
    };

    wayland = {
      enable = lib.mkEnableOption "Wayland support for Ringboard";
      package = lib.mkPackageOption pkgs "ringboard-wayland" { };
    };
  };

  config = lib.mkIf (cfg.x11.enable || cfg.wayland.enable) {
    home.packages = [ cfg.client.package ];

    systemd.user.services.ringboard-server = {
      Unit = {
        Description = "Ringboard server";
        Documentation = [ "https://github.com/SUPERCILEX/clipboard-history" ];
        After = [ "multi-user.target" ];
      };

      Install = {
        WantedBy = [ "multi-user.target" ];
      };

      Service = {
        Type = "notify";
        Slice = "session-ringboard.slice";
        Restart = "on-failure";
        Environment = "RUST_LOG=trace";
        ExecStart = "${
            if cfg.x11.enable then cfg.x11.package else cfg.wayland.package
          }/bin/ringboard-server";
      };
    };

    systemd.user.services.ringboard-listener = {
      Unit = {
        Description = "Ringboard clipboard listener";
        Documentation = [ "https://github.com/SUPERCILEX/clipboard-history" ];
        Requires = [ "ringboard-server.service" ];
        After = [
          "ringboard-server.service"
          "graphical-session.target"
        ];
        BindsTo = [ "graphical-session.target" ];
      };

      Install = {
        WantedBy = [ "graphical-session.target" ];
      };

      Service = {
        Type = "exec";
        Slice = "session-ringboard.slice";
        Restart = "on-failure";
        Environment = [ "RUST_LOG=trace" ];
        ExecStart = pkgs.writeShellScript "ringboard-listener" (
          if cfg.x11.enable && cfg.wayland.enable then
            ''
              if [ "''${XDG_SESSION_TYPE:?}" = "wayland" ]; then
                exec '${cfg.wayland.package}'/bin/ringboard-wayland
              else
                exec '${cfg.x11.package}'/bin/ringboard-x11
              fi
            ''
          else if cfg.wayland.enable then
            ''
              exec '${cfg.wayland.package}'/bin/ringboard-wayland
            ''
          else
            ''
              exec '${cfg.x11.package}'/bin/ringboard-x11
            ''
        );
      };
    };

    systemd.user.slices.session-ringboard.Unit = {
      Description = "Ringboard clipboard services";
    };
  };

  meta.maintainers = with lib.maintainers; [ blokyk ];
}
