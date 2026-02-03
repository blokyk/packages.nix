{
  testers,
  ...
}:
testers.runNixOSTest {
  name = "with-defined-settings";

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

          host = "server";
          port = 9876;
          baseUrl = "/my-syncyomi/";

          checkForUpdates = false;
        };
      };
    };

  testScript = ''
    start_all()
    server.wait_for_unit("syncyomi.service")
    server.wait_for_open_port(9876, addr = "server")

    # kill two birds with one stone and check both up-ness AND base url
    resp = server.succeed("curl --fail http://server:9876")
    assert '<base href="/my-syncyomi/">' in resp, f"the server's response didn't contain expected '<base href=\"/my-syncyomi/\">' html tag: {resp}"
  '';
}
