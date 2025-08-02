{ config, inputs, pkgs, lib, unstablePkgs, username, ... }:

let
  cleanshotPackage = import ../programs/cleanshot { inherit pkgs; };
  wallpaper = ../../data/wallpapers/enchanted_forest_giant_by_billy_christian.jpg;

in

{
  home.stateVersion = "23.11";

  imports = [
    ../modules/iterm2
    ../programs/iterm2
    ../programs/git

  ];

  programs = {
    ssh = {
      enable = true;

      extraConfig = ''
        StrictHostKeyChecking no
      '';

      matchBlocks = {
        # Use SSH over HTTPS for GitHub and point to your SOPS-managed key
        "github.com" = {
          hostname = "ssh.github.com";
          identityFile = "~/.ssh/id_ed25519";
          identitiesOnly = true;
        };

        "*" = {
          user = "root";
        };
      };
    };

    bat = {
      enable = true;
      config.theme = "Nord";
    };

    gpg = {
      enable = true;
    };

  };


  #  IMPORTANT: Use this if decide to use specific env per project
  #  Installs and enables nix-direnv allows you to write .envrc files like this:
  #  and it will automatically load a Nix shell environment (shell.nix or flake.nix) when entering that directory.
  #  use nix

  #  programs.direnv = {
  #    enable = true;
  #    nix-direnv.enable = true;
  #  };

  programs.eza = {
    enable = true;
    enableZshIntegration = true;
    icons = "auto";
    git = true;
    extraOptions = [
      "--group-directories-first"
      "--header"
      "--color=auto"
    ];
  };

  programs.fzf = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    tmux.enableShellIntegration = true;
    defaultOptions = [
      "--no-mouse"
    ];
  };

  programs.lf.enable = true;

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    enableBashIntegration = true;

    settings = pkgs.lib.importTOML ../../data/starship/starship.toml;
  };

  programs.bash.enable = true;

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;


    shellAliases = {
      cl = "clear";
      lg = "lazygit";
      tscl = "npx tsc";
      dev = "cd ~/Developer";
    };
    initContent = ''
      cat() {
        bat --paging=always "$@"
      }
    '';
  };

  programs.home-manager.enable = true;
  programs.nix-index.enable = true;

  programs.zoxide.enable = true;

  home.activation.manageCleanshot = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        echo "❯❯❯❯ 🔒 Installing CleanShot X into /Applications"
    #      rm -f "$HOME/Applications/CleanShot X.app"

         if [ -d "${cleanshotPackage}/Applications/CleanShot X.app" ]; then
           if [ ! -e "/Applications/CleanShot X.app" ]; then
             echo "Linking to /Applications"
             ln -s  "${cleanshotPackage}/Applications/CleanShot X.app" "/Applications/"
           else
             echo "❯❯❯❯ ⓘ Skipping — already exists in /Applications"
           fi
         fi

  '';

  home.activation.makeDirectoryDeveloper = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    echo "❯❯❯❯ ⓘ Creating Developer directory if it doesn't exist"

    if [ ! -d "/Users/${username}/Developer" ]; then
      echo "❯❯❯❯ ⓘ Creating /Users/${username}/Developer directory..."
      mkdir -p "/Users/${username}/Developer"
      chown ${username}:staff "/Users/${username}/Developer"
    else
      echo "❯❯❯❯ ⓘ Developer directory already exists. Skipping creation."
    fi

  '';

  home.activation.manageShortcutsToTakeEffectImmediately = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    echo "❯❯❯❯ ✅ Managing shortcuts to take effect immediately "

    /usr/bin/sudo -u ${username} /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u

  '';

  home.activation.setWallpaper = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    echo "❯❯❯❯ Setting wallpaper"
    
      WALLPAPER_PATH=${wallpaper}

      if [ -f "$WALLPAPER_PATH" ]; then
        echo "❯❯❯❯ ✅ Setting wallpaper to $WALLPAPER_PATH"
        /usr/bin/osascript <<EOF
        tell application "System Events"
          set picture of every desktop to POSIX file "$WALLPAPER_PATH"
        end tell
    EOF
      else
        echo "❯❯❯❯ ❌ Wallpaper file not found at: $WALLPAPER_PATH"
      fi

  '';

}
