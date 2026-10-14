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

    homebrew-switch = {
      url = "github:Sanyam-G/homebrew-switch";
      flake = false;
    };

    homebrew-tinycast = {
      url = "github:abue-ammar/homebrew-tinycast";
      flake = false;
    };

    homebrew-artginzburg-tap = {
      url = "github:artginzburg/homebrew-tap";
      flake = false;
    };

    mattpocock-skills = {
      url = "github:mattpocock/skills";
      flake = false;
    };

    homebrew-claude-usage = {
      url = "github:hamed-elfayome/homebrew-claude-usage";
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
        edit-secrets = mkApp "edit-secrets" ''
          MACHINE="''${1:-}"
          if [ -z "$MACHINE" ]; then
            echo "Usage: nix run .#edit-secrets -- <machine>"
            if [ -d secrets ]; then
              echo "Available: $(cd secrets && printf '%s ' */ | tr -d /)"
            else
              echo "Available: none (no secrets/ directory)"
            fi
            exit 1
          fi

          REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
          SECRETS_FILE="$REPO_ROOT/secrets/$MACHINE/secrets.enc.yaml"

          if [ ! -f "$SECRETS_FILE" ]; then
            echo "Error: $SECRETS_FILE not found"
            exit 1
          fi

          # sops edits via a private temp file and only re-encrypts on a clean exit
          rc=0
          # macOS sops looks in ~/Library/Application Support by default, not ~/.config
          SOPS_AGE_KEY_FILE="''${SOPS_AGE_KEY_FILE:-$HOME/.config/sops/age/keys.txt}" \
            EDITOR="''${EDITOR:-nano}" ${pkgs.sops}/bin/sops "$SECRETS_FILE" || rc=$?
          # 200 = sops "file has not changed"
          if [ "$rc" -eq 200 ]; then
            echo "No changes for $MACHINE"
            exit 0
          fi
          [ "$rc" -eq 0 ] || exit "$rc"
          echo "Secrets updated for $MACHINE"
        '';
        check-secrets = mkApp "check-secrets" ''
          MACHINE="''${1:-$(scutil --get LocalHostName)}"
          REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
          SECRETS_FILE="$REPO_ROOT/secrets/$MACHINE/secrets.enc.yaml"
          AGE_KEY="$HOME/.config/sops/age/keys.txt"

          if [ ! -f "$SECRETS_FILE" ]; then
            echo "No secrets configured for $MACHINE ($SECRETS_FILE not found) — skipping."
            exit 0
          fi

          if [ ! -f "$AGE_KEY" ]; then
            echo "Error: age key not found at $AGE_KEY"
            exit 1
          fi

          if SOPS_AGE_KEY_FILE="$AGE_KEY" ${pkgs.sops}/bin/sops --decrypt "$SECRETS_FILE" > /dev/null; then
            echo "OK: $SECRETS_FILE decrypts cleanly with $AGE_KEY"
          else
            echo "Error: failed to decrypt $SECRETS_FILE"
            exit 1
          fi
        '';
        scan-keys = mkApp "scan-keys" ''
          cd "$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
          fail=0

          # -l: print filenames only, never the key itself
          # Per file so an unreadable file (grep exit 2) fails the scan instead of being skipped
          while IFS= read -r -d "" f; do
            [ -e "$f" ] || continue
            rc=0
            grep -qIE \
              -e '-----BEGIN ([A-Z]+ )?PRIVATE KEY-----' \
              -e 'AGE-SECRET-KEY-1[0-9A-Z]{20,}' -- "$f" 2>/dev/null || rc=$?
            if [ "$rc" -eq 0 ]; then
              echo "Error: private key material in $f"
              fail=1
            elif [ "$rc" -gt 1 ]; then
              echo "Error: cannot read $f"
              fail=1
            fi
          done < <(git ls-files -z -co --exclude-standard -- ':!secrets/secrets_example.yaml')

          for f in $(git ls-files -co --exclude-standard 'secrets/*/*.yaml'); do
            if ! grep -q '^sops:' "$f"; then
              echo "Error: $f is not sops-encrypted"
              fail=1
            fi
          done

          [ "$fail" -eq 0 ] && echo "OK: no private keys or plaintext secrets"
          exit "$fail"
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
          echo "❯❯❯❯ · Bootstrap shell ready. First build (darwin-rebuild isn't installed yet):"
          echo '  nix build ".#darwinConfigurations.$(scutil --get LocalHostName).system"'
          echo '  sudo ./result/sw/bin/darwin-rebuild switch --flake ".#$(scutil --get LocalHostName)"'
          echo "  Afterwards: nix run .#rebuild"
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
