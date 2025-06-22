{ pkgs, username,sops, ... }:
{
  imports = [
    ./custom-dock.nix
  ];

    sops.secrets."ssh/id_ed25519" = {
        sopsFile = ./secrets/flow48/id_ed25519.enc.yaml;
        path = "/Users/${username}/.ssh/id_ed25519";
        owner = username;
        mode = "0600";
    };

  homebrew = {
    casks = [
      "slack"
      "tunnelblick"
    ];
  };
}
