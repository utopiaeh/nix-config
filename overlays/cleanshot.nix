final: prev: {
  cleanshot = prev.stdenv.mkDerivation {
    pname = "cleanshot";
    version = "4.7.6";

    src = prev.fetchurl {
      url = "https://updates.getcleanshot.com/v3/CleanShot-X-4.7.6.dmg";
      sha256 = "677178b8060c5d579d5a534792c2b9649c835b1d07aa307f18a28a73307b55";
    };

    unpackPhase = ''
      # Mount the dmg
      hdiutil attach -nobrowse -readonly ${toString src} -mountpoint $TMPDIR/mount
    '';

    installPhase = ''
      mkdir -p $out/Applications
      cp -R $TMPDIR/mount/CleanShot\ X.app $out/Applications/
      hdiutil detach $TMPDIR/mount
    '';

    phases = [ "unpackPhase" "installPhase" ];

    meta = with prev.lib; {
      description = "CleanShot X - Screenshot and screen recording app";
      homepage = "https://cleanshot.com/";
      platforms = platforms.darwin;
    };
  };
}
