# common-packages.nix
{ inputs, pkgs, ... }:
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

    # Nix tools
    nixd

    # Minikube and kubectl for Kubernetes development
    minikube
    kubectl

    # Handy way to save and run project-specific commands
    just
    just-lsp
  ];
}
