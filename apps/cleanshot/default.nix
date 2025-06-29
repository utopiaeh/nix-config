

{ pkgs, ... }:

pkgs.stdenv.mkDerivation rec {
  pname = "cleanshot";
  version = "4.7.6";
  src = pkgs.fetchurl {
    url = "https://cleanshot.com/download/CleanShotX-${version}.zip";
    sha256 = "677178b8060c5e3d579d5a534792c2b9649c835b1d07aa307f18a28a73307b55";
  };
  installPhase = ''
    mkdir -p $out/Applications
    cp -r CleanShot.app $out/Applications/
  '';
  meta = {
    platforms = [ "x86_64-darwin" "aarch64-darwin" ];
    description = "CleanShot X - best screenshot tool for macOS";
    homepage = "https://cleanshot.com";
  };
}
