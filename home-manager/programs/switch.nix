{ lib, ... }:

{
  # Sanyam-G/switch — https://github.com/Sanyam-G/switch
  # Hotkey bindings aren't declared here: Switch stores them as NSKeyedArchiver-encoded
  # binary blobs, not plain values `defaults import` can express.
  targets.darwin.defaults."com.sanyamgarg.switch" = {
    "switch.backgroundBlur" = "medium";
    "switch.disableAnimations" = true;
    "switch.hideMenuBarIcon" = true;
    "switch.hideMinimizedWindows" = false;
    "switch.includeWindowlessApps" = true;
    "switch.mruMixSpaces" = false;
    "switch.shiftTapReverses" = false;
    "switch.showHintStrip" = true;
    "switch.showNumberKeyHints" = true;
    "switch.showStoplights" = false;
    "switch.showThumbnails" = true;
    "switch.showTitleFirst" = false;
    "switch.thumbnailHeight" = 130;
    "switch.typeToFilter" = false;
    "switch.verticalList" = false;
    "switch.verticalShowHeader" = false;
    "switch.verticalShowPreview" = false;
    "switch.verticalShowStoplights" = false;
  };

  # Homebrew core also has a "switch" cask (NCH audio converter) that installs to the same
  # Switch.app, and brew bundle only checks the short token, so it never notices a swap.
  # Runs after the homebrew step, so it can swap the app back itself.
  home.activation.fixSwitchApp = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    id=$(/usr/bin/defaults read /Applications/Switch.app/Contents/Info CFBundleIdentifier 2>/dev/null || true)
    if [ -n "$id" ] && [ "$id" != "com.sanyamgarg.switch" ]; then
      echo "❯❯❯❯ · /Applications/Switch.app is $id, replacing with Sanyam-G Switch..."
      export HOMEBREW_NO_AUTO_UPDATE=1
      if ! { run /opt/homebrew/bin/brew uninstall --cask switch \
        && run /opt/homebrew/bin/brew install --cask sanyam-g/switch/switch; }; then
        echo "❯❯❯❯ ✗ Switch swap failed. Fix by hand:" >&2
        echo "  brew uninstall --cask switch && brew install --cask sanyam-g/switch/switch" >&2
      fi
    fi
  '';
}
