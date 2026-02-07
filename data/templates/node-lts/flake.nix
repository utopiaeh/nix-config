{
  description = "Template Node.js project flake with direnv support";

  inputs = {
    # Upstream Nixpkgs
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Helper library for multi-platform flakes
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          # Allow unfree if needed, adjust per policy
          config.allowUnfree = true;
        };

        # Default Node version for this template.
        # You can change this (e.g. nodejs_22) in each project.
        nodejs = pkgs.nodejs_20;
      in
      {
        # Default development shell for `use flake` (direnv) or `nix develop`
        devShells.default = pkgs.mkShell {
          packages = [
            nodejs
            pkgs.nodePackages_latest.pnpm
            pkgs.nodePackages_latest.yarn
            pkgs.nodePackages_latest.typescript
          ];

          # Export common Node/JS tooling env vars
          NODE_ENV = "development";

          # Optional: point tools to the project-local node_modules/.bin
          shellHook = ''
            # Prefer project-local binaries
            if [ -d "$PWD/node_modules/.bin" ]; then
              export PATH="$PWD/node_modules/.bin:$PATH"
            fi

            echo "Loaded Node dev shell:"
            echo "  - Node: $(node --version 2>/dev/null || echo 'not available')"
            echo "  - Pnpm: $(pnpm --version 2>/dev/null || echo 'not available')"
            echo "  - Yarn: $(yarn --version 2>/dev/null || echo 'not available')"
          '';
        };
      }
    );
}
