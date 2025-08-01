{
  # macOS configuration
  system = {
    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToEscape = true; # remap CapsLock to Escape
    };

    defaults = {
      NSGlobalDomain.AppleInterfaceStyle = "Dark";
      NSGlobalDomain.AppleShowAllExtensions = true;
      NSGlobalDomain.AppleShowScrollBars = "Always";
      NSGlobalDomain.NSUseAnimatedFocusRing = false;
      NSGlobalDomain.NSNavPanelExpandedStateForSaveMode = true;
      NSGlobalDomain.NSNavPanelExpandedStateForSaveMode2 = true;
      NSGlobalDomain.PMPrintingExpandedStateForPrint = true;
      NSGlobalDomain.PMPrintingExpandedStateForPrint2 = true;
      NSGlobalDomain.NSDocumentSaveNewDocumentsToCloud = false;
      NSGlobalDomain.ApplePressAndHoldEnabled = false;
      NSGlobalDomain.InitialKeyRepeat = 25;
      NSGlobalDomain.KeyRepeat = 2;
      NSGlobalDomain."com.apple.mouse.tapBehavior" = 1;
      NSGlobalDomain.NSWindowShouldDragOnGesture = true;
      NSGlobalDomain.NSAutomaticSpellingCorrectionEnabled = false;
      LaunchServices.LSQuarantine = false; # disables "Are you sure?" for new apps
      loginwindow.GuestEnabled = false;
      finder.FXPreferredViewStyle = "Nlsv";

      universalaccess = {
        reduceMotion = false; # Reduce motion for accessibility
      };
    };
  };
}
