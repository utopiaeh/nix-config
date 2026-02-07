{
  description = "ESP32-S3 Rust dev shell (using esp-rs-nix)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    esp-rs-nix.url = "github:leighleighleigh/esp-rs-nix";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      esp-rs-nix,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };
        espToolchain = esp-rs-nix.packages.${system}.esp-rs;
      in
      {
        devShells.default = pkgs.mkShell {
          packages = [
            espToolchain
            pkgs.rust-analyzer
            pkgs.espflash
            pkgs.ldproxy
            pkgs.esp-generate
          ];

          # Make rustup/cargo use the esp-rs toolchain in this shell
          # RUSTUP_TOOLCHAIN = espToolchain;

          # Nice defaults for your project
          CARGO_BUILD_TARGET = "xtensa-esp32s3-none-elf";
          RUST_BACKTRACE = 1;
        };
      }
    );
}
