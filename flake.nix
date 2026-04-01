{
  inputs = {
    # Base nixpkgs for macOS
    nixpkgs-darwin.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs = {
      follows = "nixpkgs-darwin";
    }; # do NOT give a url here

    # nix-darwin
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs-darwin";

    # home-manager
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs-darwin";

    # homebrew integration
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
    homebrew-bundle = {
      url = "github:homebrew/homebrew-bundle";
      flake = false;
    };

    homebrew-macshot = {
      url = "github:sw33tLie/homebrew-macshot";
      flake = false;
    };

    # Secrets management
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    # Rust overlay
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    claude-code = {
      url = "github:sadjow/claude-code-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { self, ... }@inputs:
    let
      inherit (self) outputs;

      libx = import ./lib { inherit inputs; };

      pkgs = inputs.nixpkgs-darwin.legacyPackages.aarch64-darwin;

      mkApp = name: text: {
        type = "app";
        program = toString (
          pkgs.writeShellApplication {
            inherit name;
            text = text;
          }
          + "/bin/${name}"
        );
      };

    in
    {

      darwinConfigurations = {
        # personal
        mac-pro = libx.mkDarwin { hostname = "mac-pro"; };

        # work
        flow48 = libx.mkDarwin { hostname = "flow48"; };
      };

      # Run with: nix run .#rebuild
      apps.aarch64-darwin = {
        rebuild = mkApp "rebuild" ''
          FLAKE=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
          sudo darwin-rebuild switch --flake "$FLAKE#$(scutil --get LocalHostName)"
        '';
        rollback = mkApp "rollback" ''
          sudo darwin-rebuild --rollback
        '';
        cleanup = mkApp "cleanup" ''
          echo "Cleaning user generations..."
          nix-collect-garbage --delete-older-than 14d

          echo "Cleaning system generations (requires sudo)..."
          sudo nix-collect-garbage --delete-older-than 14d
        '';
      };

      # Bootstrap env for fresh machines: nix develop
      devShells.aarch64-darwin.default = pkgs.mkShell {
        packages = with pkgs; [
          git
          sops
          age
          ssh-to-age
        ];
        shellHook = ''
          echo "❯❯❯❯ · Bootstrap shell ready — run: nix run .#build-switch"
        '';
      };

      templates = {
        node = {
          path = ./templates/node-lts;
          description = "Node.js 22 project (nodejs, pnpm, yarn, typescript)";
        };
        esp32-rust = {
          path = ./templates/esp32-rust;
          description = "ESP32-S3 Rust project (espflash, ldproxy, esp-generate)";
        };
        api-rust = {
          path = ./templates/api-rust;
          description = "Rust API project with Diesel CLI (PostgreSQL)";
        };
        default = self.templates.node;
      };

    };

}
