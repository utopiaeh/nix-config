---
description: Add a package, app, alias or env var to the right place in nix-config
argument-hint: <package | app | alias | env var> [machine]
allowed-tools: Bash(nix search:*), Bash(brew search:*), Bash(brew info:*)
---

Add `$ARGUMENTS` to this nix-darwin repo.

1. Find it: `nix search nixpkgs <name>` for CLI tools; GUI apps go through Homebrew casks (`brew search --cask <name>`). Prefer nixpkgs for CLI tools, casks for GUI apps. If several matches, ask which one.
2. Pick the file from README "Where to add things":
   | What | Where |
   |---|---|
   | GUI app | `homebrew.casks` in `hosts/common/darwin/homebrew.nix` |
   | CLI tool, system-wide | `environment.systemPackages` in `hosts/common/common-packages.nix` |
   | CLI tool, personal | `home.packages` in `home-manager/profiles/base.nix` |
   | Shell alias | `programs.zsh.shellAliases` in `home-manager/profiles/base.nix` |
   | Env var | `home.sessionVariables` in `home-manager/profiles/base.nix` |
   | One machine only | `hosts/darwin/<machine>/default.nix` or `home-manager/profiles/<machine>.nix` |
   If a `home-manager/programs/<tool>.nix` module exists or the tool has a `programs.<tool>` home-manager option with config worth declaring, use that instead.
3. Check it isn't already declared (grep the repo). Keep the list's existing order (alphabetical if it is).
4. Secrets (tokens, keys, passwords) never go in `.nix` files: tell the user to add them with `nix run .#edit-secrets -- <machine>` and reference them through sops-nix.
5. Run `/nix-check`.
