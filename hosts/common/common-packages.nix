{ inputs, pkgs, ... }:
let
  inherit (inputs) nixpkgs;
  # Add the rust-overlay to get `withComponents`
  rustOverlay = import (builtins.fetchTarball {
    url = "https://github.com/oxalica/rust-overlay/archive/master.tar.gz";
  }) { };

  pkgsWithRust = import nixpkgs {
    overlays = [ rustOverlay.overlays.default ];
  };

  rustWithComponents = pkgsWithRust.rust-bin.stable.latest.withComponents [
     "rustc"
     "cargo"
     "rustfmt"
     "clippy"
     "llvm-tools-preview"
   ];
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
    rustWithComponents
    rustPlatform.rustLibSrc
    rust-analyzer
    cargo-llvm-cov

    # Nix tools
    nixd

    # Minikube and kubectl for Kubernetes development
    minikube
    kubectl

  ];
}
