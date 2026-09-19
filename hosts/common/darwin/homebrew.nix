{
  homebrew = {
    enable = true;

    global = {
      autoUpdate = false;
    };

    onActivation = {
      cleanup = "uninstall"; # auto-remove casks not listed here (keeps app data/prefs)
      autoUpdate = false;
      upgrade = true;
    };

    # taps derived from nix-homebrew.taps (see lib/default.nix)

    casks = [
      # "raycast"

      "telegram"
      "iterm2"

      "google-chrome"
      "zen"

      "spotify"
      "notion"

      # Utils
      "logi-options+"
      "artginzburg/tap/wheelclick"
      "transmission"
      "pearcleaner"
      "crisp"
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

      "sanyam-g/homebrew-switch/switch"
      "abue-ammar/homebrew-tinycast/tinycast@beta"
    ];

    masApps = {
      "Amphetamine" = 937984704;
    };
  };
}
