{
  config,
  lib,
  pkgs,
  username,
  ...
}:

let
  caskNames = lib.concatMapStringsSep " " (c: lib.escapeShellArg c.name) config.homebrew.casks;
in
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

      "claude"
      "telegram"

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

      "macshot"

      "sanyam-g/switch/switch"
      "abue-ammar/homebrew-tinycast/tinycast@beta"
      "hamed-elfayome/claude-usage/claude-usage-tracker"
    ];

    masApps = {
      "Amphetamine" = 937984704;
      "Xcode" = 497799835;
    };
  };

  # Gatekeeper stays on (LSQuarantine default) for everything else; only apps from the casks
  # declared above skip the "downloaded from the Internet" prompt. Homebrew removed --no-quarantine.
  system.activationScripts.postActivation.text = lib.mkAfter ''
    echo "❯❯❯❯ · Removing quarantine from declared Homebrew casks..."
    apps=$(sudo --user=${username} --set-home env HOMEBREW_NO_AUTO_UPDATE=1 \
      /opt/homebrew/bin/brew info --json=v2 --cask ${caskNames} 2>/dev/null \
      | ${pkgs.jq}/bin/jq -r '.casks[].artifacts[] | select(has("app")) | .target // empty' || true)
    while IFS= read -r app; do
      if [ -d "$app" ] && xattr -p com.apple.quarantine "$app" >/dev/null 2>&1; then
        xattr -dr com.apple.quarantine "$app" || true
      fi
    done <<< "$apps"
  '';
}
