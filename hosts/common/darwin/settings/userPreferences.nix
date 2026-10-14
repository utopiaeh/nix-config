{
  system.defaults.CustomUserPreferences = {
    "com.apple.finder" = {
      # No typed nix-darwin equivalent; the rest lives in system.defaults.finder (system.nix)
      DisableAllAnimations = true;
      WarnOnEmptyTrash = false;
      FXArrangeGroupViewBy = "Name";
      FXPreferredGroupBy = "Name";
    };
    "com.apple.WindowManager" = {
      GloballyEnabled = false; # Stage Manager off
      AutoHide = false;
    };
    "com.apple.desktopservices" = {
      # Avoid creating .DS_Store files on network or USB volumes
      DSDontWriteNetworkStores = true;
      DSDontWriteUSBStores = true;
    };
    "com.apple.dock" = {
      # Bottom-right hot corner (check System Settings → Desktop & Dock → Hot Corners for the current label)
      "wvous-br-corner" = 1;
      "wvous-br-modifier" = 0;
    };
    "com.apple.Safari" = {
      # Privacy: don’t send search queries to Apple
      UniversalSearchEnabled = false;
      SuppressSearchSuggestions = true;
    };
    "com.apple.AdLib" = {
      allowApplePersonalizedAdvertising = false;
    };
    "com.apple.TimeMachine".DoNotOfferNewDisksForBackup = true;
    # Prevent Photos from opening automatically when devices are plugged in
    "com.apple.ImageCapture".disableHotPlug = true;
    # Also in programs.iterm2.extraPrefs; the iTerm2 module only recopies its plist when it
    # changes, so this rewrite on every switch keeps the setting enforced
    "com.googlecode.iterm2".PromptOnQuit = false;
    # Spotlight's ⌘Space is disabled in disableHotkeys.nix; Tinycast takes it over
    "com.tinycast.app.beta"."hotkey.togglePalette" = builtins.toJSON {
      combo._0 = {
        carbonKeyCode = 49;
        carbonModifiers = 256;
      };
    };
    "com.apple.menuextra.clock" = {
      ShowAMPM = true;
      ShowDate = 0; # 0 = When Space Allows
      ShowDayOfWeek = true;
      TimeAnnouncementsEnabled = false;
      TimeAnnouncementsIntervalIdentifier = "EveryHourInterval";
    };
    "com.apple.controlcenter" = {
      "NSStatusItem Visible AirDrop" = false;
      "NSStatusItem VisibleCC Battery" = true;
      "NSStatusItem VisibleCC WiFi" = true;
      "NSStatusItem VisibleCC Clock" = true;
    };
    "com.google.Chrome" = {
      AppleEnableSwipeNavigateWithScrolls = true;
      DisablePrintPreview = true;
      PMPrintingExpandedStateForPrint2 = true;
    };

  };

  # Read from /Library/Preferences, so a per-user write has no effect
  system.defaults.CustomSystemPreferences = {
    "com.apple.SoftwareUpdate" = {
      AutomaticCheckEnabled = true;
      # Check for software updates daily, not just once per week
      ScheduleFrequency = 1;
      # Download newly available updates in background
      AutomaticDownload = 1;
      # Install System data files & security updates
      CriticalUpdateInstall = 1;
    };
    # App Store app auto-update
    "com.apple.commerce".AutoUpdate = true;
  };
}
