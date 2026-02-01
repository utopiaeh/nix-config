{ inputs, pkgs, ... }:

let
  inherit (inputs) nixpkgs;

  # Optional wrapper for LLVM coverage if you need it
  cargoLlvmCovWrapped = pkgs.writeShellScriptBin "cargo-llvm-cov" ''
    export LLVM_COV=${pkgs.rustc.llvmPackages.llvm}/bin/llvm-cov
    export LLVM_PROFDATA=${pkgs.rustc.llvmPackages.llvm}/bin/llvm-profdata
    exec ${pkgs.cargo-llvm-cov}/bin/cargo-llvm-cov "$@"
  '';
in
{
  # Global environment variables for all shells/IDEs
  environment.variables = {
    CARGO_HOME = "$HOME/.cargo";
    RUSTUP_HOME = "$HOME/.rustup";
    PATH = "$HOME/.cargo/bin:$PATH";
    RUST_SRC_PATH = "${pkgs.rustPlatform.rustLibSrc}/lib/rustlib/src/rust/library";

    # Rust Analyzer flags for deep analysis
    RA_LAUNCHER_CARGO_ALL_FEATURES = "true";
    RA_LAUNCHER_PROC_MACRO_ENABLE = "true";
  };

  # Rust tooling installed via nix
  environment.systemPackages = with pkgs; [
    rustc
    cargo
    rustfmt
    clippy
    rust-analyzer
    rustPlatform.rustLibSrc
    cargoLlvmCovWrapped
  ];

  # Post-activation: confirm Rust installation without rustup
  system.activationScripts.postActivation.text = ''
    echo "❯ Rust toolchain is managed via Nix."
    rustc --version
    cargo --version
    rust-analyzer --version
  '';
}
