{ config, ... }:

let
  profileSource = ./profiles.yaml;
  settingSource = ./settings.yaml;
  targetPath = "${config.home.homeDirectory}/.config/flashspace";
in
{
  home = {
    file.".config/scripts/backup_flashspace.sh" = {
      source = ./backup_flashspace.sh;
      executable = true;
    };
  };

  home.activation.installFlashSpaceConfig = config.lib.dag.entryAfter [ "writeBoundary" ] ''
    echo "❯❯❯❯ · Installing FlashSpace profile and settings..."
    mkdir -p "${targetPath}"
    cmp -s ${profileSource} "${targetPath}/profiles.yaml" || cp ${profileSource} "${targetPath}/profiles.yaml"
    cmp -s ${settingSource} "${targetPath}/settings.yaml" || cp ${settingSource} "${targetPath}/settings.yaml"
  '';
}
