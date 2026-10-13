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
    # Seed only: FlashSpace owns these after first run; save UI changes back with backup_flashspace.sh
    [ -e "${targetPath}/profiles.yaml" ] || install -m 644 ${profileSource} "${targetPath}/profiles.yaml"
    [ -e "${targetPath}/settings.yaml" ] || install -m 644 ${settingSource} "${targetPath}/settings.yaml"
  '';
}
