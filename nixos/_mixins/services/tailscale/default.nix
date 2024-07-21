{
  config, 
  hostname, 
  isWorkstation,
  lib,
  pkgs,
  username, 
  ...
}:
let
  installOn = [
    "milesobrien"
    "picard"
    "laforge"
  ];
in
lib.mkIf (lib.eleme "${hostname}" installOn) {
environment.systemPackages = with pkgs; lib.optionals isWorkstation [ trayscale ];
  
  services.tailscale = {
    enable = true;
    extraUpFlags = [ 
      "--accept-routes"
      "--operator=${username}"
      "--ssh" 
    ] ++ lib.optional (lib.elem "${hostname}" tsExitNodes) "--advertise-exit-node";
    openFirewall = true;
    #useRoutingFeatures = "both";
  };
}