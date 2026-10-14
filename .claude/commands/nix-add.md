---
description: Add a package, app, alias or env var to the right place in nix-config
argument-hint: <package | app | alias | env var> [machine]
allowed-tools: Bash(nix search:*), Bash(brew search:*), Bash(brew info:*)
---

Add `$ARGUMENTS` to this nix-darwin repo.

1. Find it: `nix search nixpkgs <name>` for CLI tools; GUI apps go through Homebrew casks (`brew search --cask <name>`). Prefer nixpkgs for CLI tools, casks for GUI apps. If several matches, ask which one.
2. Pick the file from the README "Where to add things" table (single source, read it). Prefer a `programs.<tool>` home-manager option over a bare package when the tool has config worth declaring.
3. Check it isn't already declared (grep the repo). Keep the list's existing order (alphabetical if it is).
4. Secrets (tokens, keys, passwords) never go in `.nix` files: tell the user to add them with `nix run .#edit-secrets -- <machine>` and reference them through sops-nix.
5. Run `/nix-check`.
