{ pkgs, ... }:

{
  home.packages = [
    (pkgs.rust-bin.stable.latest.default.override {
      extensions = [
        "rust-src"
        "llvm-tools"
      ];
    })

    pkgs.rust-analyzer
    pkgs.cargo-llvm-cov
  ];

  home.sessionVariables.CARGO_HOME = "$HOME/.cargo";
}
