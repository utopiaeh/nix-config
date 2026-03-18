{
  description = "ESP32-S3 Rust project";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    rust-overlay.url = "github:oxalica/rust-overlay";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      nixpkgs,
      rust-overlay,
      flake-utils,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        overlays = [ (import rust-overlay) ];
        pkgs = import nixpkgs { inherit system overlays; };
      in
      {
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            # Flashing and project tooling
            espflash
            ldproxy
            esp-generate

            # Stable Rust for host-side tooling (cargo, clippy, rustfmt)
            # The Xtensa toolchain for the target is managed by espup — see README
            rust-bin.stable.latest.default
          ];

          # Source the esp toolchain environment if espup has been run
          shellHook = ''
            if [ -f "$HOME/export-esp.sh" ]; then
              source "$HOME/export-esp.sh"
              echo "❯❯❯❯ · ESP32-S3 dev environment loaded (Xtensa toolchain active)"
            else
              echo "❯❯❯❯ ⚠ Xtensa toolchain not found."
              echo "      Run 'espup install' once to set it up, then re-enter this shell."
            fi
          '';

          env = {
            RUST_BACKTRACE = "1";
          };
        };
      }
    );
}
