{ inputs, outputs, config, lib, hostname, system, username, pkgs, unstablePkgs, ... }:
let
  inherit (inputs) nixpkgs;
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

  ];

  system.stateVersion = 5;
  # Set primary user for system-wide activation
  system.primaryUser = "${username}";

  users.users.${username}.home = "/Users/${username}";

  nix = {
    enable = false;
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      warn-dirty = false;
    };
    channel.enable = false;
  };

  nixpkgs = {
    config.allowUnfree = true;
    hostPlatform = lib.mkDefault "${system}";
  };

  environment.variables = { };

  environment.systemPackages = with pkgs; [];

  fonts.packages = [
    pkgs.nerd-fonts.fira-code
    pkgs.nerd-fonts.fira-mono
    pkgs.nerd-fonts.hack
    pkgs.nerd-fonts.jetbrains-mono
  ];

  # pins to stable as unstable updates very often
  programs.nix-index.enable = true;


  homebrew = {
    enable = true;

    global = {
      autoUpdate = true;
    };

    onActivation = {
      cleanup = "zap";
      #cleanup = "uninstall"; // uninstall all brews and casks but keep files
      #cleanup = "none"; // do not cleanup anything
      autoUpdate = true;
      upgrade = true;
    };

    brews = [
      #"borders"
    ];

    taps = [
      #"FelixKratz/formulae" #sketchybar
    ];

    casks = [
      # Fonts
      "font-fira-code"
      "font-fira-code-nerd-font"
      "font-fira-mono-for-powerline"
      "font-hack-nerd-font"
      "font-jetbrains-mono-nerd-font"
      "font-meslo-lg-nerd-font"

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
      "postman"
      "figma"

      "lulu" #Disalbe connection to network
      "flashspace" # FlashSpace is a tool for managing and sharing window layouts on macOS

      "iterm2"

      "visual-studio-code"

    ];

    masApps = {
      "Amphetamine" = 937984704;
    };
  };

  # environment.pathsToLink = [ "/Applications" ];

  # Add ability to used TouchID for sudo authentication
  security.pam.services.sudo_local.touchIdAuth = true;


  system.activationScripts.postActivation.text = ''
        # echo "❯❯❯❯ ✅ Remove the quarantine attribute recursively from all .app folders inside /Applications..."
        # sudo find /Applications -type d -name "*.app" -exec xattr -r -d com.apple.quarantine {} \; || true

        echo "❯❯❯❯ ✅ Installing default settings for IntelliJIdea..."
        ${setupIntelliJIdeaScript} ${username} ${pathIntelliJIdeaLayout}

        echo "❯❯❯❯ ✅ Installing FlashSpace profile and settings..."
        mkdir -p "${targetPathFlashspace}"
        cp ${profileSource} "${targetPathFlashspace}/profiles.yaml"
        cp ${settingSource} "${targetPathFlashspace}/settings.yaml"

  '';

}
