{ pkgs, ... }:

{
  # Rust toolchain (stable, latest)
  environment.systemPackages = [
    (pkgs.rust-bin.stable.latest.default.override {
      extensions = [
        "rust-src"
        "rustfmt"
        "clippy"
        "llvm-tools"
      ];
    })

    pkgs.rust-analyzer
    pkgs.pkg-config
    pkgs.openssl
    pkgs.cargo-llvm-cov

    pkgs.rustup
  ];

  # Ensure Cargo binaries are on PATH (usually already true)
  environment.variables = {
    CARGO_HOME = "$HOME/.cargo";
  };

}
