{
  description = "Rust API project with Diesel";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      nixpkgs,
      flake-utils,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        diesel-cli = pkgs.diesel-cli.override {
          sqliteSupport = false;
          mysqlSupport = false;
          postgresqlSupport = true;
        };
      in
      {
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            diesel-cli
            postgresql
          ];

          shellHook = ''
            echo "❯❯❯❯ · Rust $(rustc --version) + Diesel CLI dev environment loaded"
          '';

          env = {
            RUST_BACKTRACE = "1";
          };
        };
      }
    );
}
