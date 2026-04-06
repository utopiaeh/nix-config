{
  config,
  username,
  pkgs,
  lib,
  ...
}:

{
  imports = [ ./custom-dock.nix ];

  sops = {
    age.keyFile = "/Users/${username}/.config/sops/age/keys.txt";
    defaultSopsFile = ../../../secrets/${config.networking.hostName}/secrets.enc.yaml;

    secrets."ssh_key" = {
      path = "/Users/${username}/.ssh/id_ed25519";
      owner = username;
      mode = "0600";
    };

  };

  homebrew.casks = [
    "slack"
    "tunnelblick"
    "discord"
  ];
}
