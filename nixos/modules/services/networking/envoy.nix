{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.envoy;
  confFile = pkgs.writeText "envoy.json" (builtins.toJSON cfg.config);

in

{
  options = {
    services.envoy = {

      enable = mkEnableOption "Envoy reverse proxy";

      configuration = mkOption {
        type = types.attr;
        default = {};
        description = "Configuration options for Envoy";
      };
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ pkgs.envoy ];
    systemd.services.envoy = {
      description = "Envoy reverse proxy";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        AmbientCapabilities = "CAP_NET_BIND_SERVICE";
        CapabilityBoundingSet = "CAP_NET_BIND_SERVICE";
        ExecStart = "${pkgs.envoy}/bin/envoy -c ${confFile}";
        DynamicUser = true;
        CacheDirectory = "envoy";
      };
    };
  };
}
