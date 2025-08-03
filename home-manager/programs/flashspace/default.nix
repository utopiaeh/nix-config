{ config, lib, username, pkgs, ... }:

{
#  home-manager.users.${username} = {
    home = {
      file.".config/scripts/backup_flashspace.sh" = {
        source = ./backup_flashspace.sh;
        executable = true;
      };

      file.".config/flashspace/profiles.yaml".source = ./profiles.yaml;
      file.".config/flashspace/settings.yaml".source = ./settings.yaml;
    };
#  };
}

