{ lib, ... }:
with lib;
let
  mkLinkLocation = name: config: {
    name = "= /" + name;
    value = config._location-config;
  };
in
cfg:
mkIf cfg.enable {

  enableACME = cfg.enableHTTPS != false;

  # these two options are mutually exclusive:
  # `addSSL` allows both http and https, and `forceSSL` forces http conns to be https
  addSSL = cfg.enableHTTPS == "both";
  forceSSL = cfg.enableHTTPS == true;

  locations = {
    "/" = mkIf (cfg.port != null) {
      proxyPass = cfg.host + ":" + (toString cfg.port);
      proxyWebsockets = true;
      recommendedProxySettings = true;
      extraConfig = ''
        client_max_body_size ${toString cfg.maxUpload};
        proxy_read_timeout ${toString cfg.timeout};
        proxy_send_timeout ${toString cfg.timeout};
        send_timeout ${toString cfg.timeout};
        ${cfg.extraConfig}
      '';
    };
  }
  // mapAttrs' mkLinkLocation cfg.links;
}
