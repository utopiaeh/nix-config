{ pkgs }:

pkgs.stdenvNoCC.mkDerivation {
  pname = "cleanshot";
  version = "4.7.7";

  src = ../../../assets/cleanshot/CleanShot-X-4.7.7.dmg;

  phases = [ "installPhase" ];

  installPhase = ''
    MOUNTPOINT=$(mktemp -d)
    /usr/bin/hdiutil attach $src -mountpoint $MOUNTPOINT -nobrowse -quiet

    mkdir -p $out/Applications
    cp -R "$MOUNTPOINT/CleanShot X.app" "$out/Applications/"

    /usr/bin/hdiutil detach $MOUNTPOINT -quiet
  '';

  meta = with pkgs.lib; {
    description = "CleanShot X screen capture utility";
    platforms = platforms.darwin;
  };
}
