{ config, lib, pkgs, ... }:

let
  profileSource = ../../../data/flashspace/profiles.yaml;
  settingSource = ../../../data/flashspace/settings.yaml;
  targetPath = "${config.home.homeDirectory}/.config/flashspace";
in {
 home.activation.flashspaceProfile = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
   echo "Installing FlashSpace profile and settings..."
   mkdir -p "${targetPath}"
   cp ${profileSource} "${targetPath}/profiles.yaml"
   cp ${settingSource} "${targetPath}/settings.yaml"
 '';
}
