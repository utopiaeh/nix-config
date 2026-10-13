---
description: Show what would change vs the running system before switching
allowed-tools: Bash(nix build:*), Bash(nix store diff-closures:*), Bash(scutil --get LocalHostName)
---

1. Build the current host: `nix build ".#darwinConfigurations.$(scutil --get LocalHostName).system" --no-link --print-out-paths`
2. Diff against the running system: `nix store diff-closures /run/current-system <out-path>`
3. Summarize: version bumps, added/removed packages, notable size changes. Flag major version jumps and anything security-relevant. Skip noise (`-man`, `-doc`, unchanged-version rebuilds).

Never switch. Tell the user to apply with `nix run .#rebuild` if it looks good.

$ARGUMENTS
