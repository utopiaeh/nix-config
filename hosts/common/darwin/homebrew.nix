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

      "telegram"
      "iterm2"

      "google-chrome"
      "zen"

      "spotify"
      "notion"

      # Utils
      "openlogi"
      "artginzburg/tap/wheelclick"
      "transmission"
      "pearcleaner"
      "crisp"
      "discord"

      "zed"
      "intellij-idea"
      "bruno"

      "figma"

      "flashspace" # FlashSpace is a tool for managing and sharing window layouts on macOS

      "docker-desktop"

      "sw33tlie/homebrew-macshot/macshot"

      "sanyam-g/homebrew-switch/switch"
      "abue-ammar/homebrew-tinycast/tinycast@beta"
      "hamed-elfayome/claude-usage/claude-usage-tracker"
    ];

    masApps = {
      "Amphetamine" = 937984704;
      "Xcode" = 497799835;
    };
  };
}
