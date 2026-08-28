{ ... }:

{
  # MrKai77/Loop — https://github.com/MrKai77/Loop
  # `keybinds` (window-snap bindings) isn't declared here: it's a JSON-encoded array
  # keyed by generated UUIDs, too fragile to hand-maintain in nix without drifting
  # from what the in-app keybind editor produces.
  targets.darwin.defaults."com.MrKai77.Loop" = {
    launchAtLogin = true;
    showDockIcon = false;
    animateWindowResizes = false;
    animationConfiguration = 4;
    respectStageManager = true;
    windowSnapping = false;
    moveCursorWithWindow = false;
    middleClickTriggersLoop = false;
    doubleClickToTrigger = false;
    hapticFeedback = false;
    previewVisibility = 0;
    previewBackgroundEnableBlur = true;
    previewUseWindowCornerRadius = false;
    radialMenuVisibility = 0;
    useSystemWindowManagerWhenAvailable = false;
  };
}
