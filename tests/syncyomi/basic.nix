{
  testers,
  ...
}:
testers.runNixOSTest {
  name = "basic";

  nodes.server =
    { ... }:
    {
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
        };
      };
    };

  testScript = ''
    start_all()
    server.wait_for_unit("syncyomi.service")
    server.wait_for_open_port(8282)

    resp = server.succeed("curl --fail http://localhost:8282/api/healthz/liveness")
    assert resp == "OK", f"the server failed the health check: {resp}"
  '';
}
