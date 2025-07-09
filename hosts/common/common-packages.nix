{ inputs, pkgs, ... }:
let
  inherit (inputs) nixpkgs;
in
{
  nixpkgs.config.allowUnfree = true;
#  nixpkgs.config.allowUnsupportedSystem = true;
  environment.systemPackages = with pkgs; [
    ## stable
    gh
    git-crypt
    go
    jetbrains-mono # font
    # terraform
    tree
    unzip
    watch
    wget
    zoxide
    lazygit #GIT GUI
#    gitui #GIT GUI
    fzf
#    Secrets
    sops
    iterm2

    nodejs
    yarn
    procps
  ];
}
