{ config, inputs, pkgs, lib, unstablePkgs, specialArgs,  ... }:
{

    imports = [
        ./base.nix
    ];

    home.packages = with pkgs; [
    #    poetry
    ];

}
