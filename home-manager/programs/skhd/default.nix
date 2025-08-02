{ config, lib, pkgs, username, ... }:

{
  services.skhd = {
    enable = true;
    skhdConfig = builtins.readFile ./skhdrc;
  };

  home-manager.users.${username} = {

    home.file.".config/skhd/scripts/toggle-chatgpt.sh" = {
      text = builtins.readFile ./scripts/toggle-chatgpt.sh;
      executable = true;
    };
  };
}


