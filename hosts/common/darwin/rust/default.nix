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
    PATH = "$HOME/.cargo/bin:$PATH";  # ensures cargo & rustc are available globally
  };

  # Rust tooling installed via nix
  environment.systemPackages = with pkgs; [
    rustc
    cargo
    rustfmt
    clippy
    rust-analyzer
    cargoLlvmCovWrapped
  ];

  # Post-activation: install rustup and essential components
  system.activationScripts.postActivation.text = ''
    if ! command -v rustc >/dev/null 2>&1; then
      echo "❯ Installing Rust via rustup..."
      rustup-init -y
    fi

    # Use stable and add components for rust-analyzer
    rustup default stable
    rustup component add rust-src rustfmt clippy rust-analyzer
  '';
}
