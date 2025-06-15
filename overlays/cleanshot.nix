self: super: {
  cleanshot = super.stdenv.mkDerivation rec {
    pname = "cleanshot";
    version = "4.7.6";

    src = super.fetchurl {

      sha256 = "677178b8060c5d579d5a534792c2b9649c835b1d07aa307f18a28a73307b55";
    };

    phases = [ "unpackPhase" "installPhase" ];

    unpackPhase = ''
      mkdir -p $TMPDIR/mount
      hdiutil attach -nobrowse -readonly "$src" -mountpoint "$TMPDIR/mount"
    '';

    installPhase = ''
      mkdir -p $out/Applications
      cp -R "$TMPDIR/mount/CleanShot X.app" $out/Applications/
      hdiutil detach "$TMPDIR/mount"
    '';

    meta = with super.lib; {
      description = "CleanShot X screenshot and screen recording app";
      homepage = "https://cleanshot.com/";
      platforms = super.lib.platforms.darwin;
      license = super.lib.licenses.unfree;
    };
  };
}
