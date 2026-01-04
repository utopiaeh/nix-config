# overlays/rust.nix
final: prev: {

  # Use rust-bin stable from the overlay
  rust-bin = prev.rust-bin.overrideAttrs (old: {
    # optional: no changes to the package itself, but you can add extensions
    default = old.stable.latest.default.override {
      extensions = [ "rust-src" ];  # needed for rust-analyzer
    };
  });

}
