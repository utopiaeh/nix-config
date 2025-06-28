{ pkgs, username, inputs, ... }:
{
  imports = [
    ./custom-dock.nix
  ];

sops = {
    defaultSopsFile = ../../../secrets/flow48/secrets.enc.yaml;
  secrets = {
    "ssh/id_ed25519" = {
    sopsFile = ../../../secrets/flow48/secrets.enc.yaml;
      path = "/Users/utopiaeh/.ssh/id_ed25519";
      mode = "0600";
      owner = "utopiaeh";
    };
  };
};

  homebrew = {
    casks = [
      "slack"
      "tunnelblick"
    ];
  };
}
