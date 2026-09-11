{
  testers
}:
testers.runNixOSTest {
  name = "cont";
  nodes.machine =
    { lib, pkgs, ... }: {
      imports = [ <home-manager/nixos> ];
      nix.nixPath = [
        "nixpkgs=${pkgs.path}"
        "home-manager=${<home-manager>}"
      ];

      # networking.useHostResolvConf = false;
      # services.resolved.enable = true;
      # networking = {
      #   # useDHCP = true;
      #   defaultGateway = {
      #     address = "192.168.1.1";
      #     interface = "eth1";
      #   };
      #   nameservers = [
      #     "8.8.8.8"
      #     "1.1.1.1"
      #   ];
      # };

      # systemd.network.networks."40-eth1" = {
      #   routes = [
      #     { Gateway = "192.168.1.1"; }
      #   ];
      # };

      programs.zsh.enable = true;

      users.users.root = {
        shell = pkgs.zsh;
      };

      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        users.root = {
          imports = [./home.nix];
          programs.zsh.enable = true;
          home.stateVersion = lib.versions.majorMinor lib.version;
        };
      };
    };

  # we can't disable the timeout, so just make it super long (1 year)
  globalTimeout = 60 * 60 * 24 * 365;

  sshBackdoor.enable = true;

  skipLint = true;
  skipTypeCheck = true;
  testScript = ''
    start_all()
    machine.wait_for_shutdown()
  '';
}
