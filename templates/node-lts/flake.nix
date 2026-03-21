{
  description = "Node.js project";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    { nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        # Change to nodejs_18, nodejs_20, nodejs_22, nodejs_23, etc.
        nodejs = pkgs.nodejs_22;
        # Bind pnpm/yarn to the selected Node version
        pnpm = pkgs.nodePackages.pnpm.override { inherit nodejs; };
      in
      {
        devShells.default = pkgs.mkShell {
          packages = [
            nodejs
            pnpm
            pkgs.yarn
            pkgs.typescript
          ];

          shellHook = ''
            echo "❯❯❯❯ · Node $(node --version) dev environment loaded"
          '';
        };
      }
    );
}
