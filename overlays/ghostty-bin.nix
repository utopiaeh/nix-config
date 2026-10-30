(final: prev: {
  # 1.4.0 fixes title-bar tabs on macOS 27; merged in nixpkgs (#579717) but not yet in nixos-unstable, drop once it is
  ghostty-bin = prev.ghostty-bin.overrideAttrs (old: rec {
    version = "1.4.0";
    src = prev.fetchurl {
      url = "https://release.files.ghostty.org/${version}/Ghostty.dmg";
      hash = "sha256-OgIHXb0kMY13hCavQd7lUH1T7MRXjt6WkS7Jzm0Y0+g=";
    };
  });
})
