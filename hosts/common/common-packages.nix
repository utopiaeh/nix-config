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
    rust
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

    skhd
  ];
}
