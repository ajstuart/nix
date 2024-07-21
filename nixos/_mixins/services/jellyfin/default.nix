{ config, lib, ... }:
let
  installOn = [ "milesobrien" ];
in
lib.mkIf (lib.elem config.networking.hostName installOn) {
  services = {
    jellyfin = {
      enable = true;
      openFirewall = true;
    };
  };
}