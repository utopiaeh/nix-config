#!/bin/bash

set -euo pipefail  # Exit on errors, undefined variables, or failed pipes

# Define paths
FLASHSAPCE_PATH="$HOME/.config/flashspace"
DEST_PATH="/Users/$USER/nix-config/home-manager/programs/flashspace"

# Define files to sync
FILES=("profiles.yaml" "settings.yaml")

# === Error Handling ===

# Check if source directory exists
if [[ ! -d "$FLASHSAPCE_PATH" ]]; then
  echo "Error: Source directory '$FLASHSAPCE_PATH' does not exist." >&2
  exit 1
fi

# Check if destination directory exists and is writable
if [[ ! -d "$DEST_PATH" ]]; then
  echo "Error: Destination directory '$DEST_PATH' does not exist." >&2
  exit 1
fi

if [[ ! -w "$DEST_PATH" ]]; then
  echo "Error: No write permission for destination directory '$DEST_PATH'." >&2
  exit 1
fi

# === File Sync Logic ===

for file in "${FILES[@]}"; do
  src_file="$FLASHSAPCE_PATH/$file"
  dest_file="$DEST_PATH/$file"
  backup_file="$DEST_PATH/backup_$file"

  # Check if the source file exists
  if [[ -f "$src_file" ]]; then
    # Backup destination file if it exists
    if [[ -f "$dest_file" ]]; then
      cp "$dest_file" "$backup_file"
      echo "Backed up $dest_file to $backup_file"
    fi

    # Sync the file
    rsync -a "$src_file" "$dest_file"
    echo "Synced $src_file to $dest_file"
  else
    echo "Warning: Source file '$src_file' not found. Skipping."
  fi
done

cd "$DEST_PATH"
if [ -n "$(git status --porcelain)" ]; then
  git add .
  git commit -m "Backup FlashSpace profiles: $(date -u +"%Y-%m-%d %H:%M:%S UTC")"
  git push origin main
fi
