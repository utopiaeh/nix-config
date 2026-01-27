{ inputs, pkgs, ... }:
let
  inherit (inputs) nixpkgs;

  cargoLlvmCovWrapped = pkgs.writeShellScriptBin "cargo-llvm-cov" ''
    export LLVM_COV=${pkgs.rustc.llvmPackages.llvm}/bin/llvm-cov
    export LLVM_PROFDATA=${pkgs.rustc.llvmPackages.llvm}/bin/llvm-profdata
    exec ${pkgs.cargo-llvm-cov}/bin/cargo-llvm-cov "$@"
  '';
in
{
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    gh
    git-crypt
    go
    jetbrains-mono
    tree
    unzip
    watch
    wget
    zoxide
    lazygit
    fzf
    sops
    neovim

    nodejs
    yarn

    # Rust tools
    rustc
    cargo
    rustfmt
    clippy
    rustPlatform.rustLibSrc  # provides the standard library for rust-analyzer
    rust-analyzer
    #

    cargoLlvmCovWrapped
    rustc.llvmPackages.llvm

    # Nix tools
    nixd

    # Minikube and kubectl for Kubernetes development
    minikube
    kubectl

  ];
}
