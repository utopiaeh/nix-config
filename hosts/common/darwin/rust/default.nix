{ pkgs, ... }:

{
  # Rust toolchain (stable, latest)
  environment.systemPackages = [
    (pkgs.rust-bin.stable.latest.default.override {
      extensions = [ "rustfmt" "clippy" "rust-src" ];
    })

    pkgs.rust-analyzer
    pkgs.pkg-config
    pkgs.openssl
  ];

  # Ensure Cargo binaries are on PATH (usually already true)
  environment.variables = {
    CARGO_HOME = "$HOME/.cargo";
  };

}
