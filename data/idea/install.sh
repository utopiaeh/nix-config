#!/usr/bin/env bash

set -euo pipefail

username="$1"
layoutPath="$2"
user_home=$(dscl . -read /Users/"$username" NFSHomeDirectory | cut -d " " -f2-)

# Find latest IntelliJ config directory (e.g. IntelliJIdea2025.1)
latest_dir=$(find "$user_home/Library/Application Support/JetBrains" -maxdepth 1 -type d -name "IntelliJIdea*" | sort -V | tail -n1)

if [ -n "$latest_dir" ]; then
  echo "❯❯❯❯ ⓘ Found IntelliJ config: $latest_dir"
  mkdir -p "$latest_dir/options"
  cp "$layoutPath" "$latest_dir/options/"
  chown "$username:staff" "$latest_dir/options/window.layouts.xml"
  echo "❯❯❯❯ ✅ Layout installed"
else
  echo "❯❯❯❯ ❌ No IntelliJ IDEA config folder found for user $username"
  exit 1
fi
