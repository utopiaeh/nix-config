{ config, ... }:

{
  # sw33tLie/macshot — https://github.com/sw33tLie/homebrew-macshot
  # Tool/action ordering (enabledTools, enabledActions, captureMenuItemOrder, ...) isn't
  # declared here: those are app-managed caches of known tool IDs, not user prefs.
  targets.darwin.defaults."com.sw33tlie.macshot.macshot" = {
    launchAtLogin = true;
    hideMenuBarIcon = false;
    statusBarIconMode = "symbol";
    statusBarIconSymbolName = "camera.aperture";
    liquidGlassTheme = true;
    hideRecordingHUD = true;
    showFloatingThumbnail = true;
    rememberLastTool = false;
    smartMarkerEnabled = false;
    beautifyEnabled = false;
    betaUpdatesEnabled = true;
    arrowReversed = false;

    filenameTemplate = "shot_{timestamp}";
    recordingFilenameTemplate = "rec_{timestamp}";
    saveDirectory = "${config.home.homeDirectory}/Pictures";

    quickCaptureMode = 1;
    ocrAction = 0;
    translateTargetLang = "ru";
    translationProvider = "google";
    uploadProvider = "gdrive";
    urlSchemeEnabled = false;

    recordKeystroke = false;
    recordMicAudio = false;
    recordSystemAudio = false;
    recordWebcam = false;
    recordingFPS = 60;
    webcamPosition = "bottomRight";
    webcamSize = "medium";

    hotkeyKeyCode = 21;
    hotkeyModifiers = 768;
    hotkeyFullScreenKeyCode = 20;
    hotkeyFullScreenModifiers = 768;
    hotkeyHistoryKeyCode = 4;
    hotkeyHistoryModifiers = 768;
    hotkeyOCRKeyCode = 23;
    hotkeyOCRModifiers = 768;
    hotkeyQuickCaptureKeyCode = 26;
    hotkeyQuickCaptureModifiers = 768;
    hotkeyRecordKeyCode = 22;
    hotkeyRecordModifiers = 768;
    hotkeyRecordFullScreenKeyCode = 28;
    hotkeyRecordFullScreenModifiers = 768;
    hotkeyScrollCaptureKeyCode = 25;
    hotkeyScrollCaptureModifiers = 768;
  };
}
