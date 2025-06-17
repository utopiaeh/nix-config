{ config, inputs, pkgs, lib, unstablePkgs, ... }:
{

  imports = [ ./base.nix ];

  home.packages = with pkgs; [
#    poetry
  ];

}
