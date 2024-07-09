{ config, hostname, lib, pkgs, ... }: {
  imports = lib.optional (builtins.pathExists (./. + "/${hostname}.nix")) ./${hostname}.nix;
  services = {
    audiobookshelf = {
      enable = true;
      host = "0.0.0.0";
      port = 8000;
      openFirewall = true;
    };
  };
}