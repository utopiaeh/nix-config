{ inputs, pkgs, ... }:
let
  inherit (inputs) nixpkgs;
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

    # Nix tools
    nixd

    # Minikube and kubectl for Kubernetes development
    minikube
    kubectl

  ];
}
