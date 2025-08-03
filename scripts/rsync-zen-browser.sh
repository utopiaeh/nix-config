#!/usr/bin/env bash
set -euo pipefail

PROFILE_PATH="$HOME/Library/Application Support/zen/Profiles"
DEST_PATH="/Users/$USER/nix-config/data/zen-browser/profiles"
mkdir -p "$DEST_PATH"

# Sync local to backup
rsync -a --delete "$PROFILE_PATH/" "$DEST_PATH"

# Optionally, commit to Git if changes
cd "$DEST_PATH"
if [ -n "$(git status --porcelain)" ]; then
  git add .
  git commit -m "Backup Zen profiles: $(date -u +"%Y-%m-%d %H:%M:%S UTC")"
  git push origin main
fi
