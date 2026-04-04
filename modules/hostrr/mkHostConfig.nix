{ lib, ... }:
cfg:
with lib;
let
  mkLinkLocation = name: config: {
    name = "= /" + name;
    value = config._location-config;
  };

  baseLocationConfig = {
    proxyPass = cfg.host + ":" + (toString cfg.port);
    proxyWebsockets = true;
    recommendedProxySettings = true;
    extraConfig = ''
      client_max_body_size ${toString cfg.maxUpload};
      proxy_read_timeout ${toString cfg.timeout};
      proxy_send_timeout ${toString cfg.timeout};
      send_timeout ${toString cfg.timeout};
    '';
  };
in
mkIf cfg.enable {
  enableACME = cfg.enableHTTPS != false;

  # these two options are mutually exclusive:
  # `addSSL` allows both http and https, and `forceSSL` forces http conns to be https
  addSSL = cfg.enableHTTPS == "both";
  forceSSL = cfg.enableHTTPS == true;

  locations = lib.mkMerge [
    { "/" = mkIf (cfg.port != null) baseLocationConfig; }
    (mapAttrs' mkLinkLocation cfg.links)
  ];
}
