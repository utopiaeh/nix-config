let
  # parameters = [ ascii keycode modifiers ]; space = 32/49; ⌃ 262144, ⌥ 524288, ⌘ 1048576
  on = modifiers: {
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
        "60" = {
          enabled = false;
        }; # ⌃ + Space -> Select previous input source
        "61" = on 786432; # ⌃ + ⌥ + Space -> Select next input source
        "64" = {
          enabled = false;
        }; # ⌘ + Space -> Spotlight
        "65" = on 1572864; # ⌘ + ⌥ + Space -> Finder search window

        # Screenshots
        "28" = {
          enabled = false;
        }; # Save picture of screen as a file
        "29" = {
          enabled = false;
        }; # Copy picture of screen to the clipboard
        "30" = {
          enabled = false;
        }; # Save picture of selected area as a file
        "31" = {
          enabled = false;
        }; # Copy picture of selected area to the clipboard
        "184" = {
          enabled = false;
        }; # Screenshot and recording options
      };
    };
  };
}
