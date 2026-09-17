{
  system.defaults.CustomUserPreferences = {
    "com.apple.finder" = {
      # No typed nix-darwin equivalent for these two
      DisableAllAnimations = true;
      WarnOnEmptyTrash = false;
      FXArrangeGroupViewBy = "Name";
      FXPreferredGroupBy = "Name";
      ShowPathbar = true;
      ShowStatusBar = true;
      "_FXSortFoldersFirst" = true;
      FXDefaultSearchScope = "SCcf"; # search the current folder by default
      NewWindowTarget = "PfDe"; # new Finder windows open to...
      NewWindowTargetPath = "file://\${HOME}/Desktop/"; # ...the Desktop
      ShowHardDrivesOnDesktop = false;
      ShowExternalHardDrivesOnDesktop = true;
      ShowRemovableMediaOnDesktop = true;
      ShowMountedServersOnDesktop = false;
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
      # No typed nix-darwin equivalent for this key
      enable-window-tool = false;
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
    "com.apple.SoftwareUpdate" = {
      AutomaticCheckEnabled = true;
      # Check for software updates daily, not just once per week
      ScheduleFrequency = 1;
      # Download newly available updates in background
      AutomaticDownload = 1;
      # Install System data files & security updates
      CriticalUpdateInstall = 1;
    };
    "com.apple.TimeMachine".DoNotOfferNewDisksForBackup = true;
    # Prevent Photos from opening automatically when devices are plugged in
    "com.apple.ImageCapture".disableHotPlug = true;
    # Turn on app auto-update
    "com.apple.commerce".AutoUpdate = true;
    "com.googlecode.iterm2".PromptOnQuit = false;
    "com.sw33tlie.macshot.macshot" = {
      hotkeyKeyCode = 21; # Capture Area: Cmd+Shift+4
      hotkeyModifiers = 768;
      "hotkeyDisabled_1" = false;
      hotkeyFullScreenKeyCode = 20; # Capture Screen: Cmd+Shift+3
      hotkeyFullScreenModifiers = 768;
      "hotkeyDisabled_2" = false;
      hotkeyRecordKeyCode = 22; # Record Area: Cmd+Shift+6
      hotkeyRecordModifiers = 768;
      "hotkeyDisabled_3" = false;
      hotkeyRecordFullScreenKeyCode = 28; # Record Screen: Cmd+Shift+8
      hotkeyRecordFullScreenModifiers = 768;
      "hotkeyDisabled_4" = false;
      hotkeyHistoryKeyCode = 4; # History: Cmd+Shift+H
      hotkeyHistoryModifiers = 768;
      "hotkeyDisabled_5" = false;
      hotkeyOCRKeyCode = 23; # Capture OCR: Cmd+Shift+5
      hotkeyOCRModifiers = 768;
      "hotkeyDisabled_6" = false;
      hotkeyQuickCaptureKeyCode = 26; # Quick Capture: Cmd+Shift+7
      hotkeyQuickCaptureModifiers = 768;
      "hotkeyDisabled_7" = false;
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
}
