{ inputs, outputs, config, lib, hostname, system, username, pkgs, unstablePkgs, ... }:
let
  inherit (inputs) nixpkgs;
  setupIntelliJIdeaScript = ./../../data/idea/install.sh;
  pathIntelliJIdeaLayout = ./../../data/idea/window.layouts.xml;
in
{

  imports = [

  ];

  users.users.${username}.home = "/Users/${username}";

  nix = {
    enable = false;
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      warn-dirty = false;
    };
    channel.enable = false;
  };
  system.stateVersion = 5;

  # Set primary user for system-wide activation
  system.primaryUser = "${username}";

  nixpkgs = {
    config.allowUnfree = true;
    hostPlatform = lib.mkDefault "${system}";
  };

  environment.variables = { };

  environment.systemPackages = with pkgs; [
    pkgs.nix
  ];

  fonts.packages = [
    pkgs.nerd-fonts.fira-code
    pkgs.nerd-fonts.fira-mono
    pkgs.nerd-fonts.hack
    pkgs.nerd-fonts.jetbrains-mono
  ];

  # pins to stable as unstable updates very often
  programs.nix-index.enable = true;


  programs.zsh = {
    enable = true;
    enableCompletion = true;
    promptInit = builtins.readFile ./../../data/mac-dot-zshrc;
  };

  homebrew = {
    enable = true;
    onActivation = {
      cleanup = "zap";
#      cleanup = "uninstall"; // uninstall all brews and casks but keep files
#      cleanup = "none"; // do not cleanup anything
      autoUpdate = true;
      upgrade = true;
    };

    global.autoUpdate = true;

    brews = [
      #"borders"
    ];
    taps = [
      #"FelixKratz/formulae" #sketchybar
    ];
    casks = [
      #    Fonts
      "font-fira-code"
      "font-fira-code-nerd-font"
      "font-fira-mono-for-powerline"
      "font-hack-nerd-font"
      "font-jetbrains-mono-nerd-font"
      "font-meslo-lg-nerd-font"
      #   System
      "raycast"
      #   Chat
      "telegram"

      "google-chrome"
      "zed"
      #   Media
      "iina"
      "spotify"
      "notion"
      #   Utils
      "logi-options+"
      "middleclick"
      "hiddenbar"
      "alt-tab"
      "transmission"
      "pearcleaner"
      "betterdisplay"

      #      AI
      "chatgpt"
      #
      "zen"
      "intellij-idea"
      "sublime-text"
      "postman"
      "figma"

      #Disalbe connection to network
      "lulu"

    ];
    masApps = {
      # these apps only available via uk apple id
      #"Logic Pro" = 634148309;
      #"MainStage" = 634159523;
      #"Garageband" = 682658836;
      #"ShutterCount" = 720123827;
      #"Teleprompter" = 1533078079;

      # "Keynote" = 409183694;
      # "Numbers" = 409203825;
      # "Pages" = 409201541;
    };
  };

  # Keyboard
  system.keyboard.enableKeyMapping = true;
  system.keyboard.remapCapsLockToEscape = false;

  # Add ability to used TouchID for sudo authentication
  security.pam.services.sudo_local.touchIdAuth = true;

  # macOS configuration
  system.defaults = {
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
  };

  system.defaults.universalaccess = {
    reduceMotion = false;
  };

  system.defaults.CustomUserPreferences = {
    "com.apple.finder" = {
      ShowExternalHardDrivesOnDesktop = true;
      ShowHardDrivesOnDesktop = false;
      ShowMountedServersOnDesktop = false;
      ShowRemovableMediaOnDesktop = true;
      _FXSortFoldersFirst = true;
      # When performing a search, search the current folder by default
      FXDefaultSearchScope = "SCcf";
      DisableAllAnimations = true;
      NewWindowTarget = "PfDe";
      NewWindowTargetPath = "file://$\{HOME\}/Desktop/";
      AppleShowAllExtensions = true;
      FXEnableExtensionChangeWarning = false;
      ShowStatusBar = true;
      ShowPathbar = true;
      WarnOnEmptyTrash = false;
    };
    "com.apple.desktopservices" = {
      # Avoid creating .DS_Store files on network or USB volumes
      DSDontWriteNetworkStores = true;
      DSDontWriteUSBStores = true;
    };
    "com.apple.dock" = {
      autohide = false;
      launchanim = false;
      static-only = false;
      show-recents = false;
      show-process-indicators = true;
      orientation = "bottom";
      tilesize = 46;
      minimize-to-application = true;
      mineffect = "scale";
      enable-window-tool = false;
    };
    "com.apple.ActivityMonitor" = {
      OpenMainWindow = true;
      IconType = 5;
      SortColumn = "CPUUsage";
      SortDirection = 0;
    };
    "com.apple.Safari" = {
      # Privacy: don’t send search queries to Apple
      UniversalSearchEnabled = false;
      SuppressSearchSuggestions = true;
    };
    "com.apple.AdLib" = {
      allowApplePersonalizedAdvertising = false;
    };
    "com.apple.SoftwareUpdate" = {
      AutomaticCheckEnabled = true;
      # Check for software updates daily, not just once per week
      ScheduleFrequency = 1;
      # Download newly available updates in background
      AutomaticDownload = 1;
      # Install System data files & security updates
      CriticalUpdateInstall = 1;
    };
    "com.apple.TimeMachine".DoNotOfferNewDisksForBackup = true;
    # Prevent Photos from opening automatically when devices are plugged in
    "com.apple.ImageCapture".disableHotPlug = true;
    # Turn on app auto-update
    "com.apple.commerce".AutoUpdate = true;
    "com.googlecode.iterm2".PromptOnQuit = false;
    "com.google.Chrome" = {
      AppleEnableSwipeNavigateWithScrolls = true;
      DisablePrintPreview = true;
      PMPrintingExpandedStateForPrint2 = true;
    };

    "com.apple.symbolichotkeys" = {
      AppleSymbolicHotKeys = {
        "60" = { enabled = false; }; # ⌘ + Space
        "61" = { enabled = true; }; # ⌃ + Space
        "64" = { enabled = false; }; # Spotlight
        "65" = { enabled = true; }; # Spotlight (secondary)

        # Screenshoots
        "28" = { enabled = false; };
        "29" = { enabled = false; };
        "30" = { enabled = false; };
        "31" = { enabled = false; };
      };
    };
  };


  system.activationScripts.postActivation.text = ''
    # Forcing shortcuts to take effect immediately
    sudo -u ${username} /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u

    #It removes the quarantine attribute recursively from all .app folders inside /Applications.
    sudo find /Applications -type d -name "*.app" -exec xattr -r -d com.apple.quarantine {} \; || true

    # Install default settings for IntelliJIdea
    ${setupIntelliJIdeaScript} ${username} ${pathIntelliJIdeaLayout}

    #Make a directory for dev staff
    mkdir -p "/Users/${username}/Developer"
    chown ${username}:staff "/Users/${username}/Developer"

  '';

}
