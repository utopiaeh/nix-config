{ pkgs, username, inputs, ... }:
{
  imports = [
    ./custom-dock.nix
  ];

sops = {
  defaultSopsFile = ../../../secrets/flow48/secrets.enc.yaml;
  age.keyFile = "/Users/${username}/.config/sops/age/keys.txt";
  secrets."ssh_key" = {
    path = "/Users/${username}/.ssh/id_ed25519";
    owner = username;
    mode = "0600";
  };
  secrets."github_token" = {
    path = "/etc/github_token";
    owner = username;
    mode = "0400";
  };
};

  homebrew = {
    casks = [
      "slack"
      "tunnelblick"
    ];
  };
}
