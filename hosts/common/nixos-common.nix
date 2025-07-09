{ pkgs, lib, inputs, stateVersion, username, ... }:
let
  inherit (inputs) nixpkgs;
in
{
  time.timeZone = "Moldova/Chisinau";
  system.stateVersion = stateVersion;

  virtualisation = {
    docker = {
      enable = true;
      autoPrune = {
        enable = true;
        dates = "weekly";
      };
    };
  };

  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      warn-dirty = false;
      trusted-users = [ "@admin" "${username}" ];
      substituters = [ "https://nix-community.cachix.org" "https://cache.nixos.org" ];
      trusted-public-keys = [ "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=" ];
    };
    # Automate garbage collection
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 5";
    };
  };

}
