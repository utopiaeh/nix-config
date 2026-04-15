{
  lib,
  system,
  username,
  pkgs,
  ...
}:
let
  setupIntelliJIdeaScript = ./../../assets/idea/install.sh;
  pathIntelliJIdeaLayout = ./../../assets/idea/window.layouts.xml;

  profileSource = ./../../home-manager/programs/flashspace/profiles.yaml;
  settingSource = ./../../home-manager/programs/flashspace/settings.yaml;
  targetPathFlashspace = "/Users/${username}/.config/flashspace";

in
{

  imports = [
    ./darwin/settings/system
    ./darwin/settings/userPreferences
    ./darwin/settings/disableHotkeys
    #./darwin/cleanshot.nix
  ];

  # sops.secrets."cleanshot_license" = {
  #   sopsFile = ../../secrets/shared/secrets.enc.yaml;
  #   owner = username;
  #   mode = "0400";
  # };

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
      "sw33tlie/homebrew-macshot"
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
      "thaw"
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

      "figma"

      "flashspace" # FlashSpace is a tool for managing and sharing window layouts on macOS

      "docker-desktop"

      "sw33tlie/homebrew-macshot/macshot"

      # Windows Manager
      "loop"

    ];

    masApps = {
      "Amphetamine" = 937984704;
    };
  };

  # environment.pathsToLink = [ "/Applications" ];

  # Add ability to used TouchID for sudo authentication
  security.pam.services.sudo_local.touchIdAuth = true;

  system.activationScripts.postActivation.text = ''
    echo "❯❯❯❯ · Removing quarantine attribute from /Applications..."
    sudo find /Applications -type d -name "*.app" -exec xattr -r -d com.apple.quarantine {} \; || true

    echo "❯❯❯❯ · Installing IntelliJ IDEA layout..."
    ${setupIntelliJIdeaScript} ${username} ${pathIntelliJIdeaLayout}

    echo "❯❯❯❯ · Installing FlashSpace profile and settings..."
    mkdir -p "${targetPathFlashspace}"
    cp ${profileSource} "${targetPathFlashspace}/profiles.yaml"
    cp ${settingSource} "${targetPathFlashspace}/settings.yaml"

  '';

}
