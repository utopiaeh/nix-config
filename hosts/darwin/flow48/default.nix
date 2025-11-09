{ config, username, pkgs, lib, ... }:
{
  imports = [
    ./custom-dock.nix
  ];

  # environment.etc."hosts".text = lib.mkAfter ''
  #   127.0.0.1 mfe.flow48dev.com
  #   127.0.0.1 mfe.flow48staging.com
  #   127.0.0.1 mfe.flow48.com
  # '';

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
    pkgs.tinygo
  ];

  homebrew = {
#  Pico2
    taps = [
#      "armmbed/formulae"
    ];

#  Pico2
    brews = [
#      "arm-none-eabi-gcc"
    ];

    casks = [
      "slack"
      "tunnelblick"
      "discord"
    ];
  };
}
