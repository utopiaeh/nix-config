{ inputs, pkgs, unstablePkgs, ... }:
let
  inherit (inputs) nixpkgs nixpkgs-unstable;
in
{
  nixpkgs.config.allowUnfree = true;
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
    fzf
  ];
}
