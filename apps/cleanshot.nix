{ pkgs, lib, ... }:

let
  version = "4.7.6";
  name = "CleanShot-X";
  url = "https://updates.getcleanshot.com/versions/CleanShot${version}.zip";
  sha256 = "677178b8060c5e3d579d5a534792c2b9649c835b1d07aa307f18a28a73307b55"; # Run nix-prefetch-url
in
pkgs.stdenv.mkDerivation {
  pname = "cleanshot";
  inherit version;

  src = pkgs.fetchurl {
    inherit url sha256;
  };

  phases = [ "unpackPhase" "installPhase" ];
  sourceRoot = ".";

  installPhase = ''
    mkdir -p $out/Applications
    cp -R "CleanShot X.app" $out/Applications/
  '';

  meta = with lib; {
    description = "CleanShot X - Screenshot and screen recording app";
    homepage = "https://cleanshot.com/";
    platforms = platforms.darwin;
  };
}
