{ config, inputs, pkgs, lib, unstablePkgs, specialArgs,  ... }:
{

    imports = [ ./base.nix ];

    home.packages = with pkgs; [
    #    poetry
    ];

#    services.ssh-agent = {
#      enable = true;
#      keys = [ "/Users/${specialArgs.username}/.ssh/id_ed25519" ];
#    };
}
