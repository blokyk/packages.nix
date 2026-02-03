rec {
  mkClient =
    {
      subdomains ? [ ],
    }:
    { lib, pkgs, ... }:
    {
      # set ip to 192.168.1.1/24
      networking.interfaces.eth1.ipv4.addresses = [
        {
          address = "192.168.1.1";
          prefixLength = 24;
        }
      ];

      # add the (sub)domain(s) from the server so we don't have to worry about dns
      networking.extraHosts = ''
        192.168.1.2 server
      ''
      + lib.join "\n" (map (sub: "192.168.1.2 " + sub + ".server") subdomains);

      # we'll need curl to query the server
      environment.systemPackages = [ pkgs.curl ];
    };

  mkServer =
    config:
    { ... }:
    {
      # set ip to 192.168.1.2/24
      networking.interfaces.eth1.ipv4.addresses = [
        {
          address = "192.168.1.2";
          prefixLength = 24;
        }
      ];
      # allow HTTP/HTTPS
      networking.firewall.allowedTCPPorts = [
        80
        443
      ];

      imports = [
        config
        ../../modules/hostrr
      ];

      services.hostrr = {
        enable = true;
        enableHTTPS = false;
        base = "server";
      };
    };

  mkTestScript = script: ''
    start_all();

    server.wait_for_unit("network.target")
    server.wait_for_unit("nginx.service")

    client.wait_for_unit("network.target")

    ${script}
  '';

  mkTest =
    {
      name,
      client,
      server,
      testScript,
    }:
    {
      name = name;

      nodes = {
        client = mkClient client;
        server = mkServer server;
      };

      testScript = mkTestScript testScript;
    };
}
