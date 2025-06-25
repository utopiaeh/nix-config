{ pkgs, username, inputs, ... }:
{
  imports = [
    ./custom-dock.nix
  ];

#  sops = {
#    age.keyFile = "/Users/utopiaeh/.config/sops/age/keys.txt"; # path to your private key
#    defaultSopsFile = ../../../../secrets/flow48/secrets.yaml; # encrypted secrets file
#    secrets."ssh/id_ed25519" = {
#      path = "/Users/utopiaeh/.ssh/id_ed25519";
#      owner = "utopiaeh";
#      mode = "0600";
#    };
#  };

  homebrew = {
    casks = [
      "slack"
      "tunnelblick"
    ];
  };
}
