{ config, lib, username, pkgs, ... }:

#let
#  profileSource = ./profiles.yaml;
#  settingSource = ./settings.yaml;
#  targetPath = "${config.home.homeDirectory}/.config/flashspace";
#in

{
  home = {
    file.".config/scripts/backup_flashspace.sh" = {
      source = ./backup_flashspace.sh;
      executable = true;
    };

#    file.".config/flashspace/profiles.yaml".text = builtins.readFile ./profiles.yaml;
#    file.".config/flashspace/settings.yaml".text = builtins.readFile ./settings.yaml;

    #    activation.flashspaceProfile = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    #      echo "❯❯❯❯ ✅ Installing FlashSpace profile and settings..."
    #      mkdir -p "${targetPath}"
    #      cp ${profileSource} "${targetPath}/profiles.yaml"
    #      cp ${settingSource} "${targetPath}/settings.yaml"
    #    '';
  };

}

