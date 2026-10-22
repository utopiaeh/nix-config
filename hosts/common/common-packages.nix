{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # Version control
    gh

    # General utilities
    # Nix curl trusts the nixpkgs CA bundle, which drops CAs Mozilla distrusts; /usr/bin/curl does not
    curl
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

  ];
}
