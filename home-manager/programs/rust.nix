{ pkgs, ... }:

{
  home.packages = [
    (pkgs.rust-bin.stable.latest.default.override {
      extensions = [
        "rust-src"
        "llvm-tools"
      ];
      # wasm32-wasip2: required to compile Zed extensions (e.g. intellij-lsp-zed dev extension)
      targets = [ "wasm32-wasip2" ];
    })

    pkgs.rust-analyzer
    pkgs.pkg-config
    pkgs.openssl
    pkgs.cargo-llvm-cov

  ];

  home.sessionVariables.CARGO_HOME = "$HOME/.cargo";
}
