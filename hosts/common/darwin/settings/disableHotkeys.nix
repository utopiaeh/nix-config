let
  # Cocoa modifier flags; a combo is their sum
  ctrl = 262144;
  opt = 524288;
  cmd = 1048576;

  off = {
    enabled = false;
  };
  # parameters = [ ascii keycode modifiers ]; space = 32 / 49
  spaceWith = modifiers: {
    enabled = true;
    value = {
      parameters = [
        32
        49
        modifiers
      ];
      type = "standard";
    };
  };
in
{
  # Replaces the whole AppleSymbolicHotKeys dict: IDs not listed fall back to macOS defaults
  system.defaults.CustomUserPreferences = {
    "com.apple.symbolichotkeys" = {
      AppleSymbolicHotKeys = {
        "60" = off; # ⌃ + Space -> Select previous input source
        "61" = spaceWith (ctrl + opt); # Select next input source
        "64" = off; # ⌘ + Space -> Spotlight
        "65" = spaceWith (cmd + opt); # Finder search window

        # Screenshots
        "28" = off; # Save picture of screen as a file
        "29" = off; # Copy picture of screen to the clipboard
        "30" = off; # Save picture of selected area as a file
        "31" = off; # Copy picture of selected area to the clipboard
        "184" = off; # Screenshot and recording options
      };
    };
  };
}
