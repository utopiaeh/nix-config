{
  lib,
  system,
  username,
  pkgs,
  ...
}:
let
  setupIntelliJIdeaScript = ./../../data/idea/install.sh;
  pathIntelliJIdeaLayout = ./../../data/idea/window.layouts.xml;

  profileSource = ./../../home-manager/programs/flashspace/profiles.yaml;
  settingSource = ./../../home-manager/programs/flashspace/settings.yaml;
  targetPathFlashspace = "/Users/${username}/.config/flashspace";

in
{

  imports = [
    ../../home-manager/programs/zsh

    ./darwin/settings/system
    ./darwin/settings/userPreferences
    ./darwin/settings/disableHotkeys
    ./darwin/rust
  ];

  system.stateVersion = 5;
  # Set primary user for system-wide activation
  system.primaryUser = "${username}";

  users.users.${username}.home = "/Users/${username}";

  time.timeZone = "Europe/Chisinau";

  nix = {
    enable = false;
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      warn-dirty = false;
    };
    channel.enable = false;

  };

  nixpkgs = {
    config.allowUnfree = true;
    hostPlatform = lib.mkDefault "${system}";
  };

  environment.variables = { };

  environment.systemPackages = [ ];

  fonts.packages = with pkgs; [
    nerd-fonts.fira-code
    nerd-fonts.fira-mono
    nerd-fonts.hack
    nerd-fonts.jetbrains-mono
    nerd-fonts.meslo-lg
  ];

  # pins to stable as unstable updates very often
  programs.nix-index.enable = true;

  homebrew = {
    enable = true;

    global = {
      autoUpdate = false;
    };

    onActivation = {
      cleanup = "zap";
      #cleanup = "uninstall"; // uninstall all brews and casks but keep files
      #cleanup = "none"; // do not cleanup anything
      autoUpdate = false;
      upgrade = true;
    };

    brews = [
      #"borders"
    ];

    taps = [
      #"FelixKratz/formulae" #sketchybar
    ];

    casks = [
      "raycast"

      "telegram"

      "google-chrome"
      "zen"

      "iina"
      "spotify"
      "notion"

      # Utils
      "logi-options+"
      "middleclick"
      "hiddenbar"
      "alt-tab"
      "transmission"
      "pearcleaner"
      "betterdisplay"

      "chatgpt"

      "zed"
      "intellij-idea"
      "sublime-text"
      "visual-studio-code"
      "postman"
      "iterm2"

      "figma"

      "lulu" # Disalbe connection to network
      "flashspace" # FlashSpace is a tool for managing and sharing window layouts on macOS
    ];

    masApps = {
      "Amphetamine" = 937984704;
    };
  };

  # environment.pathsToLink = [ "/Applications" ];

  # Add ability to used TouchID for sudo authentication
  security.pam.services.sudo_local.touchIdAuth = true;

  system.activationScripts.postActivation.text = ''


    echo "❯❯❯❯ ✓⃝ Installing default settings for IntelliJIdea..."
    ${setupIntelliJIdeaScript} ${username} ${pathIntelliJIdeaLayout}

    echo "❯❯❯❯ ✓⃝ Installing FlashSpace profile and settings..."
    mkdir -p "${targetPathFlashspace}"
    cp ${profileSource} "${targetPathFlashspace}/profiles.yaml"
    cp ${settingSource} "${targetPathFlashspace}/settings.yaml"

  '';

}
