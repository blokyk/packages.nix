{
  pkgs,
  mkTest,
  ...
}:
pkgs.testers.nixosTest (mkTest {
  name = "links-on-base";

  client = { };

  server = { ... }: {
    services.hostrr = {
      hosts = {
        ".".links = {
          "hello".file = pkgs.writeText "hello.txt" "hello world";

          "social/md".url = "https://hachyderm.io/@blokyk";
          "long".url = "/a/very/long/path";
          "sc".url = "/social/md";

          "robots.txt" = {
            file = pkgs.writeText "robots.txt" "NO HUMANS HERE";
            content-type = "text/x-robots";
          };
        };
      };
    };
  };

  testScript = ''
    resp = client.succeed("curl --fail http://server/hello")
    assert "hello world" in resp, f"`/hello` didn't respond with expected content 'hello world', instead got: {resp}"

    resp = client.succeed("curl --fail -v http://server/social/md 2>&1")
    assert "301 Moved Permanently" in resp, f"`/social/md` didn't return a redirect, instead got: {resp}"
    assert "Location: https://hachyderm.io/@blokyk\r\n" in resp, f"`/social/md` didn't redirect correctly, instead got: {resp}"

    resp = client.succeed("curl --fail -v http://server/long 2>&1")
    assert "301 Moved Permanently" in resp, f"`/long` didn't return a redirect, instead got: {resp}"
    assert "Location: http://server/a/very/long/path\r\n" in resp, f"`/long` didn't redirect correctly, instead got: {resp}"

    resp = client.succeed("curl --fail -v http://server/sc 2>&1")
    assert "301 Moved Permanently" in resp, f"`/sc` didn't return a redirect, instead got: {resp}"
    assert "Location: http://server/social/md\r\n" in resp, f"`/sc` didn't redirect correctly, instead got: {resp}"

    resp = client.succeed("curl --fail -v http://server/robots.txt 2>&1")
    assert "NO HUMANS HERE" in resp, f"`/robots.txt` didn't return expected content 'NO HUMANS HERE', instead got: {resp}"
    assert "Content-Type: text/x-robots\r\n" in resp, f"`/sc` didn't have the return type 'text/x-robots', instead got: {resp}"

    # it shouldn't respond when the link isn't exact
    client.fail("curl --fail http://server/hello/world")
    client.fail("curl --fail http://server/world/hello")
    client.fail("curl --fail http://server/hello")
  '';
})