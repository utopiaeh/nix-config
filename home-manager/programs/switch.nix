{ ... }:

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
}
