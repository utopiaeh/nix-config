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
    (pkgs.rust-bin.stable.latest.default)  # includes rustc, cargo, rustfmt, clippy, rust-src
    pkgs.rust-analyzer


  ];
}
