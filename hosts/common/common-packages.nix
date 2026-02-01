# common-packages.nix
{ inputs, pkgs, ... }:
{
  nixpkgs.config.allowUnfree = true;
  nix-darwin.extraConfig = ''
    environment.variables = {
      CARGO_HOME = "$HOME/.cargo";
      RUSTUP_HOME = "$HOME/.rustup";
      PATH = "$HOME/.cargo/bin:$PATH";
      RUST_SRC_PATH = "${pkgs.rustPlatform.rustLibSrc}/lib/rustlib/src/rust/library";
      RA_LAUNCHER_CARGO_ALL_FEATURES = "true";
      RA_LAUNCHER_PROC_MACRO_ENABLE = "true";
    };
  '';
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


  ];
}
