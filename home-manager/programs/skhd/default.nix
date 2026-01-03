{ config, lib, pkgs, username, ... }:

let
  skhdWrapper = pkgs.writeShellScriptBin "skhd-wrapper" ''
    exec ${pkgs.skhd}/bin/skhd "$@"
  '';
in

{
  services.skhd = {
    enable = true;
    package = pkgs.skhd;
    skhdConfig = builtins.readFile ./skhdrc;
  };

}
