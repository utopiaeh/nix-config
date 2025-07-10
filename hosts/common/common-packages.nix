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
    jetbrains-mono # font
    tree
    unzip
    watch
    wget
    zoxide
    lazygit #GIT GUI
    fzf
    sops
    iterm2

    nodejs
    yarn


  ];
}
