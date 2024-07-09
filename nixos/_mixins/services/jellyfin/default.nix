{ config, hostname, lib, pkgs, ... }: {
  imports = lib.optional (builtins.pathExists (./. + "/${hostname}.nix")) ./${hostname}.nix;
  services = {
    jellyfin = {
      enable = true;
      openFirewall = true;
    };
  };
}