{ config, username, pkgs, ... }:
{
  imports = [
    ./custom-dock.nix
  ];


  sops = {
    # It might fix the issue with sops not finding the age key file on macOS
    age.sshKeyPaths = [ "/Users/${username}/.ssh/id_ed25519" ];
    defaultSopsFile = ../../../secrets/${config.networking.hostName}/secrets.enc.yaml;
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

  environment.systemPackages = with pkgs; [
    pkgs.ngrok
  ];

  homebrew = {
    casks = [
      "slack"
      "tunnelblick"
    ];
  };
}
