#!/usr/bin/env bash

# Copy files from flashspace config and backup existing ones
flashspace_dir="$HOME/.config/flashspace"

if [ -d "$flashspace_dir" ]; then
  echo "✅ Found flashspace config: $flashspace_dir"

  for file in "profiles.yaml" "settings.yaml"; do
    src="$flashspace_dir/$file"
    dst="./$file"

    if [ -e "$src" ]; then
      if [ -e "$dst" ]; then
        cp -R "$dst" "./backup_$file"
        echo "🔁 Existing $file backed up as backup_$file"
      fi

      cp -R "$src" "$dst"
      echo "📁 Copied $file to current directory"
    else
      echo "⚠️ $file not found in $flashspace_dir"
    fi
  done
else
  echo "❌ No flashspace config directory found at $flashspace_dir"
  exit 1
fi
