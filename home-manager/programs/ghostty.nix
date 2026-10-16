{ ... }:

{
  # Real copies instead of symlinks so Spotlight and the Dock handle Nix apps
  targets.darwin = {
    linkApps.enable = false;
    copyApps.enable = true;
  };

  programs.ghostty = {
    enable = true;
    # ponytail: app from the ghostty@tip cask (homebrew.nix), because title-bar tabs are broken in
    # Ghostty 1.3.1 on macOS 27 (ghostty-org/ghostty discussions 14244, 14303; fixed for 1.4).
    # Once pkgs.ghostty-bin is 1.4+, use it here again and drop the cask.
    package = null;

    settings = {
      font-family = "MesloLGL Nerd Font";
      font-size = 16;

      background = "#15191e";
      foreground = "#dbdbdb";
      palette = [
        "0=#000000"
        "1=#ed7482"
        "2=#57bf37"
        "3=#f2a96f"
        "4=#7cb4f7"
        "5=#b93ec1"
        "6=#9dcbfa"
        "7=#c7c7c7"
        "8=#606060"
        "9=#ef766d"
        "10=#8cf67a"
        "11=#fefb7e"
        "12=#6a71f6"
        "13=#f07ef8"
        "14=#55ffff"
        "15=#feffff"
      ];
      background-opacity = 0.93;
      background-blur = 3;

      window-width = 120;
      window-height = 22;
      cursor-style = "block";
      # Tabs integrated into the title bar, per fredrikaverpil.github.io/blog/2024/12/04/ghostty-on-macos
      macos-titlebar-style = "tabs";
      macos-titlebar-proxy-icon = "hidden";
      window-title-font-family = "MesloLGL Nerd Font";
      window-new-tab-position = "end";
      confirm-close-surface = false;
      # ⌘⇧T (undo) reopens a closed tab, but only within undo-timeout
      undo-timeout = "30s";

      # iTerm2 habit: ⌘⇧D opens a tab in the same folder; Ghostty's split-down moves to ⌘⌥D
      keybind = [
        "super+shift+d=new_tab"
        "super+alt+d=new_split:down"
        "ctrl+shift+left_bracket=previous_tab"
        "ctrl+shift+right_bracket=next_tab"
        "ctrl+shift+comma=move_tab:-1"
        "ctrl+shift+period=move_tab:1"
      ];
    };
  };
}
