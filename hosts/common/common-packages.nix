{ pkgs, ... }:
{
  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    gh
    git-crypt
    go
    tree
    unzip
    watch
    wget
    zoxide
    lazygit
    fzf
    sops
    neovim

    # A benchmarking tool for HTTP services, useful for testing and optimizing web applications
    wrk

    # Node envirement and package manager
    nodejs
    yarn

    # Nix development tools
    nixd
    nil

    # Minikube and kubectl for Kubernetes development
    minikube
    kubectl

    # Handy way to save and run project-specific commands
    just
    just-lsp

  ];
}
