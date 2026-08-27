{
  homebrew = {
    enable = true;

    global = {
      autoUpdate = false;
    };

    onActivation = {
      cleanup = "check";
      autoUpdate = false;
      upgrade = true;
    };

    # taps derived from nix-homebrew.taps (see lib/default.nix)

    casks = [
      "telegram"

      "google-chrome"
      "zen"

      "spotify"
      "notion"

      # Utils
      "logi-options+"
      "middleclick"
      "hiddenbar"
      "transmission"
      "pearcleaner"
      "betterdisplay"
      "discord"

      "chatgpt"

      "zed"
      "sublime-text"
      "visual-studio-code"
      "postman"

      "figma"

      "flashspace" # FlashSpace is a tool for managing and sharing window layouts on macOS

      "docker-desktop"

      "sw33tlie/homebrew-macshot/macshot"

      # Windows Manager
      "loop"

      "sanyam-g/homebrew-switch/switch"
    ];

    masApps = {
      "Amphetamine" = 937984704;
    };
  };
}
