{
  testers,
  ...
}: testers.runNixOSTest {
  name = "with-defined-settings";

  nodes.server =
    { ... }: {
      imports = [ ../../modules/syncyomi ];

      # create the required session secret file
      systemd.tmpfiles.settings."10-syncyomi-secret" = {
        "/var/lib/syncyomi/secret".f = {
          argument = "00112233445566778899AABBCCDDEEFF";
        };
      };

      services.syncyomi = {
        enable = true;
        settings = {
          sessionSecretFile = "/var/lib/syncyomi/secret";
          writeLogFile = true;
        };
      };
    };

  testScript = ''
    start_all()
    server.wait_for_unit("syncyomi.service")
    server.wait_for_open_port(8282)

    # check that logs exist and are a file
    server.succeed("test -f /var/log/syncyomi/syncyomi.log")
  '';
}