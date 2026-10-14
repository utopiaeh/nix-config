---
description: Validate nix-config changes locally (mirrors CI) without switching
allowed-tools: Bash(nix run .#scan-keys), Bash(nixfmt --check:*), Bash(nix flake check:*), Bash(nix build:*), Bash(git ls-files:*), Bash(git diff:*), Bash(scutil --get LocalHostName)
---

Validate the current working tree of this nix-darwin repo. Run each step, stop at the first failure, and report the real error output.

0. Secrets: `nix run .#scan-keys`. This repo is public. On failure, list the file names only, never print or read the key/secret contents, and tell the user to remove the file and rotate the key if it was ever committed. Public keys (`*.pub`, age recipients in `.sops.yaml`) are fine.
1. Format: `nixfmt --check` on changed/new `.nix` files only (`git ls-files -m -o --exclude-standard '*.nix'`). Some untouched files are not formatted yet; don't flag those.
2. Eval: `nix flake check --no-build`
3. Build current host: `nix build ".#darwinConfigurations.$(scutil --get LocalHostName).system" --no-link`
   - Also build the other host (`mac-pro` / `flow48`) unless every change is under `hosts/darwin/<this-host>/` or `home-manager/profiles/<this-host>.nix`. CI builds both.
   - New untracked files are invisible to the flake ("path does not exist"). Tell the user to `git add` them; don't stage yourself. To validate meanwhile, use `path:.#...` instead of `.#...`.

Never run `darwin-rebuild switch`, `nix run .#rebuild` or anything with `sudo`. On success, tell the user to apply with `nix run .#rebuild`.

$ARGUMENTS
