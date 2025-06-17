#!/usr/bin/env bash

username="$1"
echo "🛠️ Applying AltTab defaults..."

sudo -u "$username" defaults write com.lwouis.alt-tab-macos alignThumbnails -string "1"
sudo -u "$username" defaults write com.lwouis.alt-tab-macos appearanceSize -string "0"
sudo -u "$username" defaults write com.lwouis.alt-tab-macos appearanceStyle -string "1"
sudo -u "$username" defaults write com.lwouis.alt-tab-macos appearanceTheme -string "2"
sudo -u "$username" defaults write com.lwouis.alt-tab-macos appearanceVisibility -string "0"
sudo -u "$username" defaults write com.lwouis.alt-tab-macos fontHeight -string "13"

sudo -u "$username" defaults write com.lwouis.alt-tab-macos fadeOutAnimation -string "false"
sudo -u "$username" defaults write com.lwouis.alt-tab-macos previewFocusedWindow -string "false"
sudo -u "$username" defaults write com.lwouis.alt-tab-macos showAppsOrWindows -string "1"
sudo -u "$username" defaults write com.lwouis.alt-tab-macos showTabsAsWindows -string "false"
sudo -u "$username" defaults write com.lwouis.alt-tab-macos showTitles -string "0"
sudo -u "$username" defaults write com.lwouis.alt-tab-macos titleTruncation -string "2"
sudo -u "$username" defaults write com.lwouis.alt-tab-macos updatePolicy -string "1"

sudo -u "$username" defaults write com.lwouis.alt-tab-macos iconSize -string "20"
sudo -u "$username" defaults write com.lwouis.alt-tab-macos maxHeightOnScreen -string "60"
sudo -u "$username" defaults write com.lwouis.alt-tab-macos maxWidthOnScreen -string "70"
sudo -u "$username" defaults write com.lwouis.alt-tab-macos windowDisplayDelay -string "0"
sudo -u "$username" defaults write com.lwouis.alt-tab-macos windowMaxWidthInRow -string "30"

sudo -u "$username" defaults write com.lwouis.alt-tab-macos hideAppBadges -string "false"
sudo -u "$username" defaults write com.lwouis.alt-tab-macos hideColoredCircles -string "false"
sudo -u "$username" defaults write com.lwouis.alt-tab-macos hideSpaceNumberLabels -string "true"
sudo -u "$username" defaults write com.lwouis.alt-tab-macos hideStatusIcons -string "true"
sudo -u "$username" defaults write com.lwouis.alt-tab-macos hideThumbnails -string "false"
sudo -u "$username" defaults write com.lwouis.alt-tab-macos hideWindowlessApps -string "false"

sudo -u "$username" defaults write com.lwouis.alt-tab-macos holdShortcut -string "⌘"
sudo -u "$username" defaults write com.lwouis.alt-tab-macos nextWindowShortcut2 -string "⇥"

sudo -u "$username" defaults write com.lwouis.alt-tab-macos menubarIcon -string "0"
sudo -u "$username" defaults write com.lwouis.alt-tab-macos menubarIconShown -string "false"
sudo -u "$username" defaults write com.lwouis.alt-tab-macos preferencesVersion -string "7.24.0"
sudo -u "$username" defaults write com.lwouis.alt-tab-macos theme -string "0"

echo "🔄 Restarting AltTab..."
sudo -u "$username" osascript -e 'quit app "AltTab"' 2>/dev/null || true
while pgrep -u "$username" -f "AltTab" >/dev/null; do sleep 0.5; done
sleep 1
sudo -u "$username" open -a "AltTab"
