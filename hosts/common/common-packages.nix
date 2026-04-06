{ pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    # Version control
    gh
    git-crypt

    # General utilities
    tree
    unzip
    watch
    wget
    wrk

    # Secrets management
    sops

    # macOS utilities
    nightlight

    # Go runtime
    go

    # Kubernetes
    minikube
    kubectl

    # Task runner
    just
    just-lsp

    # Windows Manager
    loop
  ];
}
