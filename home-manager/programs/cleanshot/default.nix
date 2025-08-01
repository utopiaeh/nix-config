{ pkgs }:

pkgs.stdenvNoCC.mkDerivation rec {
  pname = "cleanshot";
  version = "4.7.6";

  src = pkgs.fetchurl {
    url = "https://updates.getcleanshot.com/v3/CleanShot-X-${version}.dmg";
    sha256 = "677178b8060c5e3d579d5a534792c2b9649c835b1d07aa307f18a28a73307b55";
  };

  # Remove nativeBuildInputs since hdiutil is a system tool, not a nix package
  nativeBuildInputs = [ ];

  phases = [ "installPhase" ];

  installPhase = ''
    set -e

    MOUNTPOINT=$(mktemp -d)
    /usr/bin/hdiutil attach $src -mountpoint $MOUNTPOINT -nobrowse -quiet

    mkdir -p $out/Applications
    cp -R "$MOUNTPOINT/CleanShot X.app" "$out/Applications/"

    /usr/bin/hdiutil detach $MOUNTPOINT -quiet
  '';

  meta = with pkgs.lib; {
    description = "CleanShot X screen capture utility";
    platforms = pkgs.lib.platforms.darwin;
  };
}
