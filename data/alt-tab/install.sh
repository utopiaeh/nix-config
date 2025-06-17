#!/bin/sh

user="$1"
plist_src="$2"

if [ ! -f "$plist_src" ]; then
  echo "❌ Error: plist source not found: $plist_src"
  exit 1
fi

user_home=$(dscl . -read /Users/"$user" NFSHomeDirectory | cut -d " " -f2-)
plist_dest="$user_home/Library/Preferences/com.lwouis.alt-tab-macos.plist"

echo "Copying $plist_src to $plist_dest"
cp "$plist_src" "$plist_dest"
chown "$user:staff" "$plist_dest"
chmod 600 "$plist_dest"

echo "Restarting AltTab..."
osascript -e 'quit app "AltTab"' 2>/dev/null || true

# Wait until AltTab actually exits
while pgrep -f "AltTab" >/dev/null; do
  echo "Waiting for AltTab to quit..."
  sleep 0.5
done

sleep 1
open -a "AltTab"
