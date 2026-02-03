{
  pkgs,
  mkTest,
  ...
}:
pkgs.testers.nixosTest (mkTest {
  name = "rproxy-simple";

  client = {
    subdomains = [ "suwa" ];
  };

  server =
    { ... }:
    {
      services.suwayomi-server = {
        enable = true;
        settings.server.port = 4567;
      };

      services.hostrr = {
        hosts = {
          "suwa".port = 4567;
        };
      };
    };

  testScript = ''
    # make sure suwayomi-server "started" (and didn't crash), and then
    # wait for it to open the port (it takes a little while to actually start)
    server.wait_for_unit("suwayomi-server.service")
    server.wait_for_open_port(4567)

    # try to request the suwayomi home page from the server
    resp = client.succeed("curl --fail http://suwa.server")

    assert "<title>Suwayomi</title>" in resp, f"`http://suwa.server` didn't return suwayomi's home page: {resp}"
  '';
})
